import 'package:cloud_functions/cloud_functions.dart';

class SendGridRepository {
  Future<void> sendContactNotification({
    required String toEmail,
    required String submitterName,
    required String submitterEmail,
    required String submitterPhone,
    required String subject,
    required String message,
    required bool isArabic,
  }) async {
    print('\n📧 [SENDGRID] Calling Firebase Cloud Function...');

    print('\n📧 [SENDGRID] Calling Firebase Cloud Function...');

    // ADD THIS:
    print('📧 [SENDGRID] Payload being sent:');
    print('   toEmail: "$toEmail"');
    print('   submitterName: "$submitterName"');
    print('   submitterEmail: "$submitterEmail"');
    print('   submitterPhone: "$submitterPhone"');
    print('   subject: "$subject"');
    print('   message: "$message"');
    print('   isArabic: $isArabic');

    final callable = FirebaseFunctions.instance
        .httpsCallable('sendContactEmail');

    final result = await callable.call({
      'toEmail': toEmail,
      'submitterName': submitterName,
      'submitterEmail': submitterEmail,
      'submitterPhone': submitterPhone,
      'subject': subject,
      'message': message,
      'isArabic': isArabic,
    });

    print('✅ [SENDGRID] Cloud Function result: ${result.data}');
  }
}