import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyTextField extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final controller;
  final bool obscureText;
  final IconData? prefixIcon, suffixIcon;
  final TextInputFormatter? inputFormatter;
  // ignore: prefer_typing_uninitialized_variables
  final keyboardType;
  // ignore: prefer_typing_uninitialized_variables
  final onChange;
  final String labelText;
  final validator;

  const MyTextField({
    super.key,
    required this.controller,
    required this.obscureText,
    required this.prefixIcon,
    required this.suffixIcon,
    this.inputFormatter,
    this.keyboardType,
    this.onChange,
    required this.labelText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextFormField(
        validator: validator,
        keyboardType: keyboardType,
        style: const TextStyle(color: Color(0xFF0070C0)),
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              color: Color(0xFF0070C0),
            ),
          ),
          border: OutlineInputBorder(
              borderSide: BorderSide(
            color: Color(0xFF0070C0),
          )),
          focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(
            color: Color(0xFF0070C0),
          )),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
            color: Color(0xFF0070C0),
          )),
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.black),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          prefixIconColor: const Color(0xFF179CF0),
          suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
        ),
      ),
    );
  }
}
