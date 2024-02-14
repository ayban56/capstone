import 'package:flutter/material.dart';

class MyCheckBox extends StatefulWidget {
  final String title;
  final bool isChecked;
  final Function(bool)? onChange;

  const MyCheckBox({
    Key? key,
    required this.title,
    required this.isChecked,
    this.onChange,
  }) : super(key: key);

  @override
  State<MyCheckBox> createState() => _MyCheckBoxState();
}

class _MyCheckBoxState extends State<MyCheckBox> {
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.isChecked;
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxMenuButton(
      value: _isChecked,
      child: Text(
        widget.title,
        style: const TextStyle(color: Color(0xFF127ABD)),
      ),
      onChanged: (newState) {
        setState(() {
          _isChecked = newState!;
        });
        if (widget.onChange != null) {
          widget.onChange!(_isChecked);
        }
      },
    );
  }
}
