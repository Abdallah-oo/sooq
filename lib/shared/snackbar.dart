import 'package:flutter/material.dart';

showSnackBar(BuildContext context, String text, {int duration = 5}) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),

      duration: Duration(seconds: duration),
      
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      backgroundColor: Colors.grey[800],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      action: SnackBarAction(
        label: 'close',
        textColor: const Color.fromARGB(
          248,
          250,
          5,
          5,
        ), // استخدام لون من تصميم التطبيق
        onPressed: () {
          // // تفعيل الزر لإخفاء الـ SnackBar
          // ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ),
  );
}
