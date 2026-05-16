class PhoneTransferRequest {
  const PhoneTransferRequest({
    required this.sourceFilePath,
    this.preferredRelativeTargetDir = 'DCIM\\Camera',
  });

  final String sourceFilePath;
  final String preferredRelativeTargetDir;
}

