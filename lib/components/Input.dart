import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final int maxLines;
  final String placeholder;

  const Input({
    super.key,
    required this.label,
    required this.controller,
    this.placeholder = '',
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: placeholder.isEmpty ? 'Digite seu $label' : placeholder,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
        ),
      ),
    );
  }
}
