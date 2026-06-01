import 'dart:convert';

import 'package:http/http.dart' as http;

import 'twilio_constants.dart';

class TwilioRepository {
  Future<void> sendOTP(String to, String channel, String locale) async {


    final credentials = '${TwilioConstants.twilioAccountSid}:${TwilioConstants.twilioAuthToken}';
    final encodedCredentials = base64Encode(utf8.encode(credentials));

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
    } else {
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
      return data['status'] == 'approved';
    } else {
      return false;
    }
  }
}
