// from https://stackoverflow.com/a/75611745
import 'package:flutter/services.dart';

class NonEmptyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return oldValue;
    }
    return newValue;
  }
}
