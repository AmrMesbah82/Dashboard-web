import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_app_admin/twailo/twilio_constants.dart';

class TwilioRepository {
  Future<void> sendOTP(String to, String channel, String locale) async {
    print('\n═══════════════════════════════════════════════════════════');
    print('📞 [TWILIO_REPO] sendOTP START');
    print('═══════════════════════════════════════════════════════════');
    print('📞 [TWILIO_REPO] Parameters:');
    print('   - To: $to');
    print('   - Channel: $channel');
    print('   - Locale: $locale');

    // Debug: Check credentials
    print('\n🔑 [TWILIO_REPO] Credentials Check:');
    print('   - Account SID: ${TwilioConstants.twilioAccountSid}');
    print('   - SID Length: ${TwilioConstants.twilioAccountSid.length} (should be 34)');
    print('   - Auth Token: ${TwilioConstants.twilioAuthToken}');
    print('   - Token Length: ${TwilioConstants.twilioAuthToken.length} (should be 32)');
    print('   - Service SID: ${TwilioConstants.twilioVerifyServiceSid}');
    print('   - Service SID Length: ${TwilioConstants.twilioVerifyServiceSid.length} (should be 34)');

    // Build credentials
    final credentials = '${TwilioConstants.twilioAccountSid}:${TwilioConstants.twilioAuthToken}';
    final encodedCredentials = base64Encode(utf8.encode(credentials));
    print('\n🔐 [TWILIO_REPO] Authorization:');
    print('   - Raw credentials format: ACCOUNT_SID:AUTH_TOKEN');
    print('   - Encoded auth (Base64): $encodedCredentials');

    // Build URL
    final url = Uri.parse(
      'https://verify.twilio.com/v2/Services/${TwilioConstants.twilioVerifyServiceSid}/Verifications',
    );
    print('\n🌐 [TWILIO_REPO] Request URL:');
    print('   - $url');

    // Build headers
    final headers = {
      'Authorization': 'Basic $encodedCredentials',
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    print('\n📋 [TWILIO_REPO] Request Headers:');
    headers.forEach((key, value) {
      print('   - $key: $value');
    });

    // Build body
    final body = {
      'To': to,
      'Channel': channel,
      'Locale': locale,
    };
    print('\n📦 [TWILIO_REPO] Request Body:');
    body.forEach((key, value) {
      print('   - $key: $value');
    });

    print('\n📤 [TWILIO_REPO] Sending HTTP POST request...');

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print('\n📥 [TWILIO_REPO] Response received:');
      print('   - Status Code: ${response.statusCode}');
      print('   - Status: ${response.statusCode == 201 ? "SUCCESS ✅" : "FAILED ❌"}');
      print('   - Response Headers:');
      response.headers.forEach((key, value) {
        print('     - $key: $value');
      });
      print('   - Response Body:');
      print('${response.body}');

      if (response.statusCode == 201) {
        print('\n✅ [TWILIO_REPO] OTP sent successfully!');

        // Try to parse response for more details
        try {
          final jsonResponse = jsonDecode(response.body);
          print('📊 [TWILIO_REPO] Parsed response data:');
          jsonResponse.forEach((key, value) {
            print('   - $key: $value');
          });
        } catch (e) {
          print('⚠️ [TWILIO_REPO] Could not parse JSON response: $e');
        }

        print('═══════════════════════════════════════════════════════════');
        print('📞 [TWILIO_REPO] sendOTP END - SUCCESS ✅');
        print('═══════════════════════════════════════════════════════════\n');
      } else {
        print('\n❌ [TWILIO_REPO] Failed to send OTP');
        print('   - Status code: ${response.statusCode}');
        print('   - Error body: ${response.body}');

        // Try to parse error response
        try {
          final jsonError = jsonDecode(response.body);
          print('   - Parsed error:');
          jsonError.forEach((key, value) {
            print('     - $key: $value');
          });
        } catch (e) {
          print('   - Could not parse error JSON: $e');
        }

        print('═══════════════════════════════════════════════════════════');
        print('📞 [TWILIO_REPO] sendOTP END - FAILED ❌');
        print('═══════════════════════════════════════════════════════════\n');

        throw Exception('Twilio API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e, stackTrace) {
      print('\n💥 [TWILIO_REPO] Exception occurred:');
      print('   - Error: $e');
      print('   - Stack trace:');
      print('$stackTrace');
      print('═══════════════════════════════════════════════════════════');
      print('📞 [TWILIO_REPO] sendOTP END - EXCEPTION ❌');
      print('═══════════════════════════════════════════════════════════\n');
      rethrow;
    }
  }

  Future<bool> verifyOTP(String to, String code) async {
    print('\n═══════════════════════════════════════════════════════════');
    print('🔍 [TWILIO_REPO] verifyOTP START');
    print('═══════════════════════════════════════════════════════════');
    print('🔍 [TWILIO_REPO] Parameters:');
    print('   - To: $to');
    print('   - Code: $code');

    // Build URL
    final url = Uri.parse(
      'https://verify.twilio.com/v2/Services/${TwilioConstants.twilioVerifyServiceSid}/VerificationCheck',
    );
    print('\n🌐 [TWILIO_REPO] Request URL:');
    print('   - $url');

    // Build credentials
    final credentials = '${TwilioConstants.twilioAccountSid}:${TwilioConstants.twilioAuthToken}';
    final encodedCredentials = base64Encode(utf8.encode(credentials));
    print('\n🔐 [TWILIO_REPO] Authorization:');
    print('   - Encoded auth (Base64): $encodedCredentials');

    // Build headers
    final headers = {
      'Authorization': 'Basic $encodedCredentials',
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    print('\n📋 [TWILIO_REPO] Request Headers:');
    headers.forEach((key, value) {
      print('   - $key: $value');
    });

    // Build body
    final body = {
      'To': to,
      'Code': code,
    };
    print('\n📦 [TWILIO_REPO] Request Body:');
    body.forEach((key, value) {
      print('   - $key: $value');
    });

    print('\n📤 [TWILIO_REPO] Sending HTTP POST request...');

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print('\n📥 [TWILIO_REPO] Response received:');
      print('   - Status Code: ${response.statusCode}');
      print('   - Response Body:');
      print('${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('\n📊 [TWILIO_REPO] Parsed response data:');
        data.forEach((key, value) {
          print('   - $key: $value');
        });

        final status = data['status'] as String?;
        final isApproved = status == 'approved';

        print('\n🔍 [TWILIO_REPO] Verification status: $status');
        print('   - Is approved: $isApproved');

        if (isApproved) {
          print('✅ [TWILIO_REPO] OTP verification SUCCESS!');
          print('═══════════════════════════════════════════════════════════');
          print('🔍 [TWILIO_REPO] verifyOTP END - SUCCESS ✅');
          print('═══════════════════════════════════════════════════════════\n');
          return true;
        } else {
          print('❌ [TWILIO_REPO] OTP verification FAILED - status is not approved');
          print('   - Actual status: $status');
          print('═══════════════════════════════════════════════════════════');
          print('🔍 [TWILIO_REPO] verifyOTP END - INVALID CODE ❌');
          print('═══════════════════════════════════════════════════════════\n');
          return false;
        }
      } else {
        print('\n❌ [TWILIO_REPO] Failed to verify OTP');
        print('   - Status code: ${response.statusCode}');
        print('   - Error body: ${response.body}');

        // Try to parse error response
        try {
          final jsonError = jsonDecode(response.body);
          print('   - Parsed error:');
          jsonError.forEach((key, value) {
            print('     - $key: $value');
          });
        } catch (e) {
          print('   - Could not parse error JSON: $e');
        }

        print('═══════════════════════════════════════════════════════════');
        print('🔍 [TWILIO_REPO] verifyOTP END - FAILED ❌');
        print('═══════════════════════════════════════════════════════════\n');
        return false;
      }
    } catch (e, stackTrace) {
      print('\n💥 [TWILIO_REPO] Exception occurred:');
      print('   - Error: $e');
      print('   - Stack trace:');
      print('$stackTrace');
      print('═══════════════════════════════════════════════════════════');
      print('🔍 [TWILIO_REPO] verifyOTP END - EXCEPTION ❌');
      print('═══════════════════════════════════════════════════════════\n');
      rethrow;
    }
  }
}