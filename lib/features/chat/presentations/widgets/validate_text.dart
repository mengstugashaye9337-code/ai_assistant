//import 'package:flutter/material.dart';

class ValidateText {
  static String? validateText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'text cannot be empty';
    }

    final text = value.trim();

    if (text.length < 2) {
      return 'Name must be at least 2 characters';
    }

    final nameRegex = RegExp(r"^[a-zA-Z\s'-]+$");

    if (!nameRegex.hasMatch(text)) {
      return 'Name can only contain letters';
    }

    return null;
  }
}
