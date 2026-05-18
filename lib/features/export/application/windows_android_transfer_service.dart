import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../domain/phone_transfer_request.dart';
import '../domain/phone_transfer_result.dart';
import 'phone_transfer_service.dart';

class WindowsAndroidTransferService implements PhoneTransferService {
  const WindowsAndroidTransferService();

  @override
  Future<PhoneTransferResult> transfer(PhoneTransferRequest request) async {
    if (!Platform.isWindows) {
      return PhoneTransferResult.skipped(
        message: 'USB transfer chỉ hỗ trợ trên Windows trong phiên bản hiện tại.',
        errorCode: PhoneTransferErrorCode.unsupportedPlatform,
      );
    }

    final source = File(request.sourceFilePath);
    if (!await source.exists()) {
      return PhoneTransferResult.failed(
        message: 'Không tìm thấy file nguồn để gửi sang điện thoại.',
        errorCode: PhoneTransferErrorCode.invalidSource,
      );
    }

    final ext = source.path.toLowerCase();
    if (!(ext.endsWith('.png') || ext.endsWith('.jpg') || ext.endsWith('.jpeg'))) {
      return PhoneTransferResult.failed(
        message: 'Định dạng ảnh không hỗ trợ cho USB transfer.',
        errorCode: PhoneTransferErrorCode.invalidSource,
      );
    }

    try {
      final result = await _transferViaWindowsMtp(
        sourceFilePath: source.path,
        preferredRelativeTargetDir: request.preferredRelativeTargetDir,
      );
      return result;
    } catch (_) {
      return PhoneTransferResult.failed(
        message: 'USB transfer gặp lỗi không xác định.',
        errorCode: PhoneTransferErrorCode.unknown,
      );
    }
  }

  Future<PhoneTransferResult> _transferViaWindowsMtp({
    required String sourceFilePath,
    required String preferredRelativeTargetDir,
  }) async {
    final escapedSource = _psSingleQuoted(sourceFilePath);
    final escapedPreferred = _psSingleQuoted(preferredRelativeTargetDir);

    final script = r'''
$ErrorActionPreference = 'Stop'

function Get-ChildFolderByName {
  param(
    [Parameter(Mandatory = $true)] $ParentFolder,
    [Parameter(Mandatory = $true)] [string] $Name
  )

  if ($null -eq $ParentFolder) { return $null }

  $items = $null
  try {
    $items = $ParentFolder.Items()
  } catch {
    return $null
  }

  if ($null -eq $items) { return $null }

  foreach ($item in $items) {
    if (-not $item.IsFolder) { continue }
    if ($item.Name -ieq $Name) {
      return $item
    }
  }
  return $null
}

function Ensure-Path {
  param(
    [Parameter(Mandatory = $true)] $RootFolder,
    [Parameter(Mandatory = $true)] [string[]] $Segments
  )

  $current = $RootFolder
  foreach ($seg in $Segments) {
    if ([string]::IsNullOrWhiteSpace($seg)) { continue }

    $nextItem = Get-ChildFolderByName -ParentFolder $current -Name $seg
    if ($null -eq $nextItem) {
      try {
        $current.NewFolder($seg)
      } catch {
        return $null
      }
      Start-Sleep -Milliseconds 250
      $nextItem = Get-ChildFolderByName -ParentFolder $current -Name $seg
      if ($null -eq $nextItem) { return $null }
    }

    try {
      $current = $nextItem.GetFolder
    } catch {
      return $null
    }

    if ($null -eq $current) { return $null }
  }

  return $current
}

function Exists-InFolder {
  param(
    [Parameter(Mandatory = $true)] $Folder,
    [Parameter(Mandatory = $true)] [string] $FileName
  )

  if ($null -eq $Folder) { return $false }

  $entries = $null
  try {
    $entries = $Folder.Items()
  } catch {
    return $false
  }

  if ($null -eq $entries) { return $false }

  foreach ($entry in $entries) {
    if ($entry.Name -ieq $FileName) {
      $size = 0
      try {
        $sizeText = $entry.ExtendedProperty('System.Size')
        if ($null -ne $sizeText -and "$sizeText" -ne '') {
          [long]::TryParse("$sizeText", [ref]$size) | Out-Null
        }
      } catch {
        $size = 0
      }

      return [PSCustomObject]@{
        Found = $true
        Size = $size
      }
    }
  }
  return [PSCustomObject]@{
    Found = $false
    Size = 0
  }
}

$source = '__SOURCE__'
$preferred = '__PREFERRED__'
$fileName = [System.IO.Path]::GetFileName($source)

if (-not (Test-Path -LiteralPath $source)) {
  @{ status='failed'; errorCode='invalidSource'; message='Khong tim thay file nguon de gui sang dien thoai.' } | ConvertTo-Json -Compress
  exit 0
}

$shell = New-Object -ComObject Shell.Application
$myComputer = $shell.Namespace(17)
if ($null -eq $myComputer) {
  @{ status='failed'; errorCode='unknown'; message='Khong the truy cap Windows Shell namespace.' } | ConvertTo-Json -Compress
  exit 0
}

$preferredSegments = $preferred -split '[\\/]'
$candidateTargets = @(
  @('DCIM', 'Camera'),
  @('Pictures', 'PhotoBooth'),
  @('DCIM', 'PhotoBooth'),
  @('Pictures')
)

if ($preferredSegments.Length -gt 0) {
  $candidateTargets = ,$preferredSegments + $candidateTargets
}

$deviceItems = @()
foreach ($item in $myComputer.Items()) {
  if (-not $item.IsFolder) { continue }
  # Bo qua cac folder he thong/PC (Desktop, Downloads, o dia...).
  # Thiet bi MTP thuong khong phai FileSystem item.
  if ($item.IsFileSystem) { continue }
  try {
    $ns = $shell.Namespace($item.Path)
    if ($null -ne $ns) {
      $deviceItems += [PSCustomObject]@{ Name = $item.Name; Namespace = $ns }
    }
  } catch {
    continue
  }
}

$attemptedTargets = @()

if ($deviceItems.Count -eq 0) {
  @{ status='skipped'; errorCode='noDevice'; message='Chua phat hien thiet bi Android o che do File Transfer (MTP). Hay mo khoa may va chon File Transfer roi export lai.' } | ConvertTo-Json -Compress
  exit 0
}

foreach ($device in $deviceItems) {
  # MTP device root thuong co 1-2 storage roots (vd: 'Internal shared storage').
  $storageRoots = @()
  try {
    foreach ($rootItem in $device.Namespace.Items()) {
      if ($rootItem.IsFolder) {
        try {
          $rootNs = $rootItem.GetFolder
          if ($null -ne $rootNs) {
            $storageRoots += [PSCustomObject]@{ Name = $rootItem.Name; Namespace = $rootNs }
          }
        } catch {
          continue
        }
      }
    }
  } catch {
    $storageRoots = @()
  }

  if ($storageRoots.Count -eq 0) {
    # Fallback neu thiet bi expose truc tiep folder media o root namespace.
    $storageRoots = @([PSCustomObject]@{ Name = $device.Name; Namespace = $device.Namespace })
  }

  foreach ($storage in $storageRoots) {
  foreach ($target in $candidateTargets) {
    $targetPathOnly = ($target -join '/')
    $attemptedTargets += "$($device.Name)/$($storage.Name)/$targetPathOnly"

    $folder = Ensure-Path -RootFolder $storage.Namespace -Segments $target
    if ($null -eq $folder) { continue }

    try {
      $folder.CopyHere($source, 16)
    } catch {
      continue
    }

    $ok = $false
    $foundSize = 0
    for ($i = 0; $i -lt 60; $i++) {
      Start-Sleep -Milliseconds 400
      $found = Exists-InFolder -Folder $folder -FileName $fileName
      if ($found.Found -eq $true -and $found.Size -gt 0) {
        $ok = $true
        $foundSize = $found.Size
        break
      }
    }

    if ($ok) {
      $targetPath = ($target -join '/') + '/' + $fileName
      @{
        status='success'
        errorCode='none'
        message="Da gui anh sang dien thoai thanh cong ($($device.Name)/$($storage.Name)/$targetPath, size=$foundSize bytes)."
        targetPath=$targetPath
        deviceName=$device.Name
        storageRoot=$storage.Name
        fileSize=$foundSize
        attemptedTargets=($attemptedTargets -join '; ')
      } | ConvertTo-Json -Compress
      exit 0
    }
  }
  }
}

@{
  status='skipped'
  errorCode='noDevice'
  message='Khong xac minh duoc file trong thu muc dich tren dien thoai. Hay dam bao may da mo khoa va USB o che do File Transfer.'
  attemptedTargets=($attemptedTargets -join '; ')
} | ConvertTo-Json -Compress
'''
        .replaceAll('__SOURCE__', escapedSource)
        .replaceAll('__PREFERRED__', escapedPreferred);

    final bridgeResult = await _runMtpBridge(script);
    if (!bridgeResult.ok) {
      return PhoneTransferResult.failed(
        message:
            'USB transfer thất bại khi gọi Windows MTP bridge. ${bridgeResult.errorMessage}',
        errorCode: PhoneTransferErrorCode.transferIo,
      );
    }

    final payload = bridgeResult.payloadJson;
    if (payload == null) {
      return PhoneTransferResult.failed(
        message:
            'USB transfer không nhận được phản hồi hợp lệ từ MTP adapter. ${bridgeResult.errorMessage}',
        errorCode: PhoneTransferErrorCode.transferIo,
      );
    }

    final status = payload['status']?.toString() ?? 'failed';
    final errorCodeRaw = payload['errorCode']?.toString() ?? 'unknown';
    final message = payload['message']?.toString() ?? 'USB transfer không có thông tin chi tiết.';
    final targetPath = payload['targetPath']?.toString();
    final deviceName = payload['deviceName']?.toString();

    final errorCode = _mapErrorCode(errorCodeRaw);

    if (status == 'success') {
      return PhoneTransferResult.success(
        message: message,
        targetPath: targetPath,
        deviceName: deviceName,
      );
    }

    if (status == 'skipped') {
      return PhoneTransferResult.skipped(
        message: message,
        errorCode: errorCode,
        deviceName: deviceName,
      );
    }

    return PhoneTransferResult.failed(
      message: message,
      errorCode: errorCode,
      deviceName: deviceName,
    );
  }

  String _psSingleQuoted(String value) {
    return value.replaceAll("'", "''");
  }

  Future<_BridgeRunResult> _runMtpBridge(String script) async {
    final tempDir = await Directory.systemTemp.createTemp('photobooth_mtp_');
    final scriptFile = File('${tempDir.path}\\mtp_bridge.ps1');

    try {
      await scriptFile.writeAsString(script, flush: true);

      // Retry 2 lần vì MTP mount có thể trễ ngay sau khi cắm cáp.
      for (var attempt = 1; attempt <= 2; attempt++) {
        final process = await Process.run(
          'powershell',
          [
            '-NoProfile',
            '-NonInteractive',
            '-ExecutionPolicy',
            'Bypass',
            '-File',
            scriptFile.path,
          ],
        ).timeout(const Duration(seconds: 120));

        final stdout = (process.stdout ?? '').toString().trim();
        final stderr = (process.stderr ?? '').toString().trim();

        Map<String, dynamic>? payload;
        String? parseError;
        final lines = stdout
            .split(RegExp(r'[\r\n]+'))
            .map((e) => e.trim())
            .where((e) => e.startsWith('{') && e.endsWith('}'))
            .toList(growable: false);
        if (lines.isNotEmpty) {
          try {
            final decoded = jsonDecode(lines.last);
            if (decoded is Map<String, dynamic>) {
              payload = decoded;
            } else if (decoded is Map) {
              payload = decoded.map((k, v) => MapEntry(k.toString(), v));
            }
          } catch (error) {
            parseError = error.toString();
          }
        }

        if (process.exitCode == 0 && payload != null) {
          return _BridgeRunResult(ok: true, payloadJson: payload);
        }

        if (attempt < 2) {
          await Future<void>.delayed(const Duration(milliseconds: 900));
          continue;
        }

        return _BridgeRunResult(
          ok: false,
          payloadJson: payload,
          errorMessage:
              'exit=${process.exitCode}; stderr=${_truncate(stderr)}; stdout=${_truncate(stdout)}; parse=${parseError ?? 'none'}',
        );
      }

      return const _BridgeRunResult(
        ok: false,
        errorMessage: 'Bridge retry loop ended unexpectedly.',
      );
    } on TimeoutException {
      return const _BridgeRunResult(
        ok: false,
        errorMessage: 'MTP bridge timeout (>120s). Make sure your phone is unlocked and set to File Transfer mode.',
      );
    } catch (error) {
      return _BridgeRunResult(ok: false, errorMessage: error.toString());
    } finally {
      try {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      } catch (_) {
        // no-op
      }
    }
  }

  String _truncate(String value, {int max = 180}) {
    if (value.length <= max) return value;
    return '${value.substring(0, max)}...';
  }

  PhoneTransferErrorCode _mapErrorCode(String raw) {
    switch (raw) {
      case 'none':
        return PhoneTransferErrorCode.none;
      case 'noDevice':
        return PhoneTransferErrorCode.noDevice;
      case 'permissionDenied':
        return PhoneTransferErrorCode.permissionDenied;
      case 'targetNotFound':
        return PhoneTransferErrorCode.targetNotFound;
      case 'transferIo':
        return PhoneTransferErrorCode.transferIo;
      case 'invalidSource':
        return PhoneTransferErrorCode.invalidSource;
      case 'unsupportedPlatform':
        return PhoneTransferErrorCode.unsupportedPlatform;
      default:
        return PhoneTransferErrorCode.unknown;
    }
  }
}

class _BridgeRunResult {
  const _BridgeRunResult({
    required this.ok,
    this.payloadJson,
    this.errorMessage,
  });

  final bool ok;
  final Map<String, dynamic>? payloadJson;
  final String? errorMessage;
}

