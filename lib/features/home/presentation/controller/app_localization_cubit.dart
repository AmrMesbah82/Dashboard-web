/// App translations for Arabic and English
class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  static AppLocalizations of(String code) => AppLocalizations(code);

  // Navigation items
  String get home => languageCode == 'ar' ? 'الرئيسية' : 'Home';
  String get services => languageCode == 'ar' ? 'الخدمات' : 'Services';
  String get aboutUs => languageCode == 'ar' ? 'من نحن' : 'About Us';
  String get contactUs => languageCode == 'ar' ? 'اتصل بنا' : 'Contact Us';
  String get career => languageCode == 'ar' ? 'الوظائف' : 'Career';

  // Add more translations as needed
  String get welcome => languageCode == 'ar' ? 'مرحباً' : 'Welcome';
  String get description => languageCode == 'ar' ? 'الوصف' : 'Description';
  String get readMore => languageCode == 'ar' ? 'اقرأ المزيد' : 'Read More';
  String get submit => languageCode == 'ar' ? 'إرسال' : 'Submit';
  String get cancel => languageCode == 'ar' ? 'إلغاء' : 'Cancel';
  String get loading => languageCode == 'ar' ? 'جاري التحميل...' : 'Loading...';
  String get error => languageCode == 'ar' ? 'خطأ' : 'Error';
  String get success => languageCode == 'ar' ? 'نجح' : 'Success';

  // Contact form
  String get name => languageCode == 'ar' ? 'الاسم' : 'Name';
  String get email => languageCode == 'ar' ? 'البريد الإلكتروني' : 'Email';
  String get phone => languageCode == 'ar' ? 'الهاتف' : 'Phone';
  String get message => languageCode == 'ar' ? 'الرسالة' : 'Message';
  String get sendMessage => languageCode == 'ar' ? 'إرسال رسالة' : 'Send Message';
}