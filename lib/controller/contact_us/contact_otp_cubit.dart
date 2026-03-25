import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_app_admin/controller/contact_us/contact_otp_state.dart';
import 'package:web_app_admin/repo/contact_us/twailio_repo.dart';

class ContactOtpCubit extends Cubit<ContactOtpState> {
  final TwilioRepository _twilioRepo = TwilioRepository();

  ContactOtpCubit() : super(OtpInitial()) {
    print('🏗️ [CONTACT_OTP_CUBIT] Cubit created');
  }

  /// Send OTP to the user's phone number
  Future<void> sendOtp({
    required String phoneNumber,
    required String locale, // 'en' or 'ar'
  }) async {
    print('\n📤 [CONTACT_OTP_CUBIT] sendOtp called');
    print('   - Phone: $phoneNumber');
    print('   - Locale: $locale');

    try {
      emit(OtpSending());
      print('   - State: OtpSending');

      // Call Twilio repository
      print('   - Calling TwilioRepository.sendOTP...');
      await _twilioRepo.sendOTP(
        phoneNumber,
        'sms', // or 'whatsapp' if you want
        locale,
      );

      print('   ✅ OTP sent successfully via Twilio');
      emit(OtpSent(phoneNumber: phoneNumber));
      print('   - State: OtpSent');
    } catch (e, stackTrace) {
      print('   ❌ Error sending OTP: $e');
      print('   ❌ Stack trace: $stackTrace');
      emit(OtpError(message: 'Failed to send OTP: $e'));
      print('   - State: OtpError');
    }
  }

  /// Verify the OTP code entered by the user
  Future<void> verifyOtp({
    required String phoneNumber,
    required String code,
  }) async {
    print('\n🔍 [CONTACT_OTP_CUBIT] verifyOtp called');
    print('   - Phone: $phoneNumber');
    print('   - Code: $code');

    try {
      emit(OtpVerifying());
      print('   - State: OtpVerifying');

      // Call Twilio repository
      print('   - Calling TwilioRepository.verifyOTP...');
      final isValid = await _twilioRepo.verifyOTP(phoneNumber, code);

      print('   - Twilio verification result: $isValid');

      if (isValid) {
        print('   ✅ OTP verified successfully!');
        emit(OtpVerified());
        print('   - State: OtpVerified');
      } else {
        print('   ❌ OTP verification failed - invalid code');
        emit(OtpError(message: 'Invalid verification code. Please try again.'));
        print('   - State: OtpError');
      }
    } catch (e, stackTrace) {
      print('   ❌ Error verifying OTP: $e');
      print('   ❌ Stack trace: $stackTrace');
      emit(OtpError(message: 'Failed to verify OTP: $e'));
      print('   - State: OtpError');
    }
  }

  /// Reset the OTP state to initial
  void reset() {
    print('🔄 [CONTACT_OTP_CUBIT] Resetting state to OtpInitial');
    emit(OtpInitial());
  }
}