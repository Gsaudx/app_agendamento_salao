import 'package:flutter/material.dart';

class FloatingButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  const FloatingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.add,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      label: Text(label),
      icon: Icon(icon),
    );
  }
}
