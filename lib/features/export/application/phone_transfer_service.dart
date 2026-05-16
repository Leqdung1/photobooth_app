import '../domain/phone_transfer_request.dart';
import '../domain/phone_transfer_result.dart';

abstract class PhoneTransferService {
  Future<PhoneTransferResult> transfer(PhoneTransferRequest request);
}

