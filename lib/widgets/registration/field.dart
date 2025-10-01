import 'package:flutter/material.dart';

class Fieldswidget extends StatelessWidget {
  final bool secure;
  final String hint;
  final TextInputType keyboard;
  final Widget shape;
  final TextEditingController? controll;
  final String? Function(String?)? validation;
  final Widget? lasticon;
  final void Function(String)? onchange;

  const Fieldswidget({
    super.key,
    required this.secure,
    required this.hint,
    required this.keyboard,
    required this.shape,
    this.controll,
    this.validation,
    this.lasticon,
    this.onchange,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onchange,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validation,
      controller: controll,
      obscureText: secure,
      keyboardType: keyboard,
      cursorColor: Colors.black,
      cursorHeight: 20,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: lasticon,
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 107, 107, 107)),
        ),
        prefixIcon: shape,
        fillColor: const Color.fromARGB(255, 255, 255, 255),
        filled: true,
        contentPadding: const EdgeInsets.fromLTRB(3, 5, 5, 5),
      ),
    );
  }
}
