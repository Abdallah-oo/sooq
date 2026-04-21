import 'package:flutter/material.dart';

class Validators {
  ///Field validator 
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required field';
    return null;
  }
///email validator 
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required field';
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }
  ///password validator 

  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required field';
    if (value.length < 8) return 'At least 8 characters';
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Must contain uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Must contain lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) return 'Must contain a number';
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Must contain special character';
    }
    return null;
  }


  ///confirm password validator 

  static String? Function(String?) confirmPassword(
    TextEditingController passwordController,
  ) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) return 'Required field';
      if (value != passwordController.text) return 'Passwords do not match';
      return null;
    };
  }

  ///phone validator 

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required field';
    final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
    if (!phoneRegex.hasMatch(value.trim())) return 'Enter a valid phone number';
    return null;
  }
}
