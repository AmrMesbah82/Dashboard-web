import 'dart:convert';

import 'package:http/http.dart' as http;

import 'twilio_constants.dart';

class TwilioRepository {
  Future<void> sendOTP(String to, String channel, String locale) async {
    print("Sending OTP to $to via $channel");

    // Debug: Check credentials
    print('Account SID: ${TwilioConstants.twilioAccountSid}');
    print('SID Length: ${TwilioConstants.twilioAccountSid.length}'); // Should be 34
    print('Token Length: ${TwilioConstants.twilioAuthToken.length}'); // Should be 32

    final credentials = '${TwilioConstants.twilioAccountSid}:${TwilioConstants.twilioAuthToken}';
    final encodedCredentials = base64Encode(utf8.encode(credentials));
    print('Encoded auth: $encodedCredentials');

    final url = Uri.parse(
      'https://verify.twilio.com/v2/Services/${TwilioConstants.twilioVerifyServiceSid}/Verifications',
    );

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Basic $encodedCredentials',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'To': to,
        'Channel': channel,
        'Locale': locale,
      },
    );

    if (response.statusCode == 201) {
      print('OTP sent successfully');
    } else {
      print('Failed to send OTP: ${response.statusCode}');
      print(response.body);
    }
  }
  Future<bool> verifyOTP(String to, String code) async {
    final url = Uri.parse(
      'https://verify.twilio.com/v2/Services/${TwilioConstants.twilioVerifyServiceSid}/VerificationCheck',
    );

    final response = await http.post(
      url,
      headers: {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('${TwilioConstants.twilioAccountSid}:${TwilioConstants.twilioAuthToken}'))}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'To': to, 'Code': code},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Verification status: ${data['status']}');
      return data['status'] == 'approved';
    } else {
      print('Failed to verify OTP: ${response.statusCode}');
      print(response.body);
      return false;
    }
  }
}
