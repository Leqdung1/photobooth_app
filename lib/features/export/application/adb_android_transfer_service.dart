import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../domain/phone_transfer_request.dart';
import '../domain/phone_transfer_result.dart';
import 'phone_transfer_service.dart';

class AdbAndroidTransferService implements PhoneTransferService {
  const AdbAndroidTransferService();

  static const String _targetDir = 'Pictures/PhotoBooth';

  @override
  Future<PhoneTransferResult> transfer(PhoneTransferRequest request) async {
    if (!Platform.isWindows) {
      return PhoneTransferResult.skipped(
        message: 'ADB transfer chỉ hỗ trợ trên Windows trong phiên bản hiện tại.',
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
        message: 'Định dạng ảnh không hỗ trợ cho ADB transfer.',
        errorCode: PhoneTransferErrorCode.invalidSource,
      );
    }

    final adbOk = await _checkAdbAvailable();
    if (!adbOk) {
      return PhoneTransferResult.skipped(
        message: 'Không tìm thấy adb trong PATH. Hãy cài Android platform-tools hoặc thêm adb vào PATH.',
        errorCode: PhoneTransferErrorCode.noDevice,
      );
    }

    final deviceState = await _getFirstDeviceState();
    if (deviceState == null) {
      return PhoneTransferResult.skipped(
        message: 'Chưa phát hiện thiết bị Android qua ADB. Hãy cắm cáp, bật USB debugging và bấm Allow trên điện thoại nếu được hỏi.',
        errorCode: PhoneTransferErrorCode.noDevice,
      );
    }

    if (deviceState == 'unauthorized') {
      return PhoneTransferResult.skipped(
        message: 'Thiết bị Android chưa được authorize ADB (unauthorized). Hãy mở khóa điện thoại và bấm Allow USB debugging.',
        errorCode: PhoneTransferErrorCode.permissionDenied,
      );
    }

    if (deviceState != 'device') {
      return PhoneTransferResult.skipped(
        message: 'Thiết bị ADB đang ở trạng thái "$deviceState". Hãy thử rút/cắm lại cáp hoặc bật lại USB debugging.',
        errorCode: PhoneTransferErrorCode.noDevice,
      );
    }

    final fileName = p.basename(source.path);
    final remotePath = '/sdcard/$_targetDir/$fileName';

    await _runAdb(
      ['shell', 'mkdir', '-p', '/sdcard/$_targetDir'],
      timeout: const Duration(seconds: 10),
    );

    final push = await _runAdb(
      ['push', source.path, remotePath],
      timeout: const Duration(seconds: 60),
    );

    if (push.exitCode != 0) {
      return PhoneTransferResult.failed(
        message: 'ADB push thất bại. ${_formatProcError(push)}',
        errorCode: PhoneTransferErrorCode.transferIo,
      );
    }

    await _tryMediaScan(remotePath);

    return PhoneTransferResult.success(
      message: 'Đã gửi ảnh sang điện thoại qua ADB: $_targetDir/$fileName',
      targetPath: remotePath,
    );
  }

  Future<bool> _checkAdbAvailable() async {
    try {
      final r = await _runAdb(
        ['version'],
        timeout: const Duration(seconds: 5),
      );
      return r.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  Future<String?> _getFirstDeviceState() async {
    final r = await _runAdb(
      ['devices'],
      timeout: const Duration(seconds: 5),
    );

    if (r.exitCode != 0) {
      return null;
    }

    final lines = (r.stdout ?? '').toString().split(RegExp(r'[\r\n]+'));
    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      if (line.toLowerCase().startsWith('list of devices')) continue;

      final parts = line.split(RegExp(r'\s+'));
      if (parts.length < 2) continue;

      final serial = parts[0].trim();
      final state = parts[1].trim();
      if (serial.isEmpty || state.isEmpty) continue;
      return state;
    }

    return null;
  }

  Future<void> _tryMediaScan(String remotePath) async {
    // Best effort only: some Android versions may not support cmd media scan.
    try {
      final r = await _runAdb(
        ['shell', 'cmd', 'media', 'scan', remotePath],
        timeout: const Duration(seconds: 10),
      );
      if (r.exitCode == 0) {
        return;
      }
    } catch (_) {
      // ignore
    }

    final uri = 'file://$remotePath';
    try {
      await _runAdb(
        ['shell', 'am', 'broadcast', '-a', 'android.intent.action.MEDIA_SCANNER_SCAN_FILE', '-d', uri],
        timeout: const Duration(seconds: 10),
      );
    } catch (_) {
      // ignore
    }
  }

  Future<ProcessResult> _runAdb(List<String> args, {required Duration timeout}) async {
    return Process.run('adb', args).timeout(timeout);
  }

  String _formatProcError(ProcessResult r) {
    final stderr = (r.stderr ?? '').toString().trim();
    final stdout = (r.stdout ?? '').toString().trim();
    final st = stderr.isEmpty ? '' : 'stderr=${_truncate(stderr)}';
    final so = stdout.isEmpty ? '' : ' stdout=${_truncate(stdout)}';
    return 'exit=${r.exitCode}; $st$so'.trim();
  }

  String _truncate(String value, {int max = 180}) {
    if (value.length <= max) return value;
    return '${value.substring(0, max)}...';
  }
}
