import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/twailo/twilio_constants.dart';

class TwilioRepository {
  Future<void> sendOTP(String to, String channel, String locale) async {

    // Debug: Check credentials

    // Build credentials
    final credentials = '${TwilioConstants.twilioAccountSid}:${TwilioConstants.twilioAuthToken}';
    final encodedCredentials = base64Encode(utf8.encode(credentials));

    // Build URL
    final url = Uri.parse(
      'https://verify.twilio.com/v2/Services/${TwilioConstants.twilioVerifyServiceSid}/Verifications',
    );

    // Build headers
    final headers = {
      'Authorization': 'Basic $encodedCredentials',
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    headers.forEach((key, value) {
    });

    // Build body
    final body = {
      'To': to,
      'Channel': channel,
      'Locale': locale,
    };
    body.forEach((key, value) {
    });


    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      response.headers.forEach((key, value) {
      });

      if (response.statusCode == 201) {

        // Try to parse response for more details
        try {
          final jsonResponse = jsonDecode(response.body);
          jsonResponse.forEach((key, value) {
          });
        } catch (e) {
        }

      } else {

        // Try to parse error response
        try {
          final jsonError = jsonDecode(response.body);
          jsonError.forEach((key, value) {
          });
        } catch (e) {
        }


        throw Exception('Twilio API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  Future<bool> verifyOTP(String to, String code) async {

    // Build URL
    final url = Uri.parse(
      'https://verify.twilio.com/v2/Services/${TwilioConstants.twilioVerifyServiceSid}/VerificationCheck',
    );

    // Build credentials
    final credentials = '${TwilioConstants.twilioAccountSid}:${TwilioConstants.twilioAuthToken}';
    final encodedCredentials = base64Encode(utf8.encode(credentials));

    // Build headers
    final headers = {
      'Authorization': 'Basic $encodedCredentials',
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    headers.forEach((key, value) {
    });

    // Build body
    final body = {
      'To': to,
      'Code': code,
    };
    body.forEach((key, value) {
    });


    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        data.forEach((key, value) {
        });

        final status = data['status'] as String?;
        final isApproved = status == 'approved';


        if (isApproved) {
          return true;
        } else {
          return false;
        }
      } else {

        // Try to parse error response
        try {
          final jsonError = jsonDecode(response.body);
          jsonError.forEach((key, value) {
          });
        } catch (e) {
        }

        return false;
      }
    } catch (e, stackTrace) {
      rethrow;
    }
  }
}