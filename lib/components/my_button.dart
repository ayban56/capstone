import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  // ignore: non_constant_identifier_names
  final String btn_name;
  final VoidCallback onPressed;
  final Color? color;
  final TextStyle? textStyle;
  final BorderSide? side;
  final RoundedRectangleBorder? radius;

  // ignore: non_constant_identifier_names
  const MyButton({
    super.key,
    // ignore: non_constant_identifier_names
    required this.btn_name,
    required this.onPressed,
    this.color,
    this.textStyle,
    this.side,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        // ignore: deprecated_member_use
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        primary: color,
        backgroundColor: color,
        fixedSize: const Size(300, 50),
        side: side,
      ),
      child: Text(
        btn_name,
        style: textStyle,
      ),
    );
  }
}
