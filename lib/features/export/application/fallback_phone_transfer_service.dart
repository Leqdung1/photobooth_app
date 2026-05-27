import '../domain/phone_transfer_request.dart';
import '../domain/phone_transfer_result.dart';
import 'phone_transfer_service.dart';

class FallbackPhoneTransferService implements PhoneTransferService {
  const FallbackPhoneTransferService(this._primary, this._fallback);

  final PhoneTransferService _primary;
  final PhoneTransferService _fallback;

  @override
  Future<PhoneTransferResult> transfer(PhoneTransferRequest request) async {
    final result = await _primary.transfer(request);
    if (result.status == PhoneTransferStatus.skipped) {
      return _fallback.transfer(request);
    }
    return result;
  }
}
