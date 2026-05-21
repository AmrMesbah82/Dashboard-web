import 'package:flutter_bloc/flutter_bloc.dart';


import '../../../../core/twailo/twilio_repository.dart';
import 'contact_us_otp_state.dart';

class ContactOtpCubit extends Cubit<ContactOtpState> {
  final TwilioRepository _twilioRepo = TwilioRepository();

  ContactOtpCubit() : super(OtpInitial()) {
  }

  /// Send OTP to the user's phone number
  Future<void> sendOtp({
    required String phoneNumber,
    required String locale, // 'en' or 'ar'
  }) async {

    try {
      emit(OtpSending());

      // Call Twilio repository
      await _twilioRepo.sendOTP(
        phoneNumber,
        'sms', // or 'whatsapp' if you want
        locale,
      );

      emit(OtpSent(phoneNumber: phoneNumber));
    } catch (e, stackTrace) {
      emit(OtpError(message: 'Failed to send OTP: $e'));
    }
  }

  /// Verify the OTP code entered by the user
  Future<void> verifyOtp({
    required String phoneNumber,
    required String code,
  }) async {

    try {
      emit(OtpVerifying());

      // Call Twilio repository
      final isValid = await _twilioRepo.verifyOTP(phoneNumber, code);


      if (isValid) {
        emit(OtpVerified());
      } else {
        emit(OtpError(message: 'Invalid verification code. Please try again.'));
      }
    } catch (e, stackTrace) {
      emit(OtpError(message: 'Failed to verify OTP: $e'));
    }
  }

  /// Reset the OTP state to initial
  void reset() {
    emit(OtpInitial());
  }
}