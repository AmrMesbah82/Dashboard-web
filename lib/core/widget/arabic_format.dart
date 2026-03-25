
import 'package:flutter/services.dart';

class ArabicNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text.replaceAllMapped(RegExp(r'[0-9]'), (match) {
      switch (match.group(0)) {
        case '0':
          return '٠';
        case '1':
          return '١';
        case '2':
          return '٢';
        case '3':
          return '٣';
        case '4':
          return '٤';
        case '5':
          return '٥';
        case '6':
          return '٦';
        case '7':
          return '٧';
        case '8':
          return '٨';
        case '9':
          return '٩';
        default:
          return match.group(0)!;
      }
    });

    return newValue.copyWith(text: newText);
  }
}