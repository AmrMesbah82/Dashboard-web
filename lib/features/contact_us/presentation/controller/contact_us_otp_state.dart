abstract class ContactOtpState {
  const ContactOtpState();
}

/// Initial state - no OTP action taken yet
class OtpInitial extends ContactOtpState {}

/// Sending OTP to the phone number
class OtpSending extends ContactOtpState {}

/// OTP sent successfully
class OtpSent extends ContactOtpState {
  final String phoneNumber;
  const OtpSent({required this.phoneNumber});
}

/// Verifying the OTP code
class OtpVerifying extends ContactOtpState {}

/// OTP verified successfully
class OtpVerified extends ContactOtpState {}

/// Error occurred during OTP send or verification
class OtpError extends ContactOtpState {
  final String message;
  const OtpError({required this.message});
}