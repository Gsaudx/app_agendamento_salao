import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final int maxLines;

  const Input({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Nome',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
      ),
    );
  }
}
