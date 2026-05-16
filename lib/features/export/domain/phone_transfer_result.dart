enum PhoneTransferStatus { success, skipped, failed }

enum PhoneTransferErrorCode {
  none,
  noDevice,
  permissionDenied,
  targetNotFound,
  transferIo,
  invalidSource,
  unsupportedPlatform,
  unknown,
}

class PhoneTransferResult {
  const PhoneTransferResult({
    required this.status,
    required this.errorCode,
    required this.message,
    this.targetPath,
    this.deviceName,
  });

  final PhoneTransferStatus status;
  final PhoneTransferErrorCode errorCode;
  final String message;
  final String? targetPath;
  final String? deviceName;

  bool get isSuccess => status == PhoneTransferStatus.success;

  factory PhoneTransferResult.success({
    required String message,
    String? targetPath,
    String? deviceName,
  }) {
    return PhoneTransferResult(
      status: PhoneTransferStatus.success,
      errorCode: PhoneTransferErrorCode.none,
      message: message,
      targetPath: targetPath,
      deviceName: deviceName,
    );
  }

  factory PhoneTransferResult.skipped({
    required String message,
    PhoneTransferErrorCode errorCode = PhoneTransferErrorCode.noDevice,
    String? deviceName,
  }) {
    return PhoneTransferResult(
      status: PhoneTransferStatus.skipped,
      errorCode: errorCode,
      message: message,
      deviceName: deviceName,
    );
  }

  factory PhoneTransferResult.failed({
    required String message,
    PhoneTransferErrorCode errorCode = PhoneTransferErrorCode.unknown,
    String? deviceName,
  }) {
    return PhoneTransferResult(
      status: PhoneTransferStatus.failed,
      errorCode: errorCode,
      message: message,
      deviceName: deviceName,
    );
  }
}

