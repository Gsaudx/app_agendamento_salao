import 'package:flutter/material.dart';

class InputDate extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const InputDate({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.datetime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: 'dd/mm/aaaa',
          suffixIcon: const Icon(Icons.calendar_today),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
        ),
        onTap: () async {
          final now = DateTime.now();
          DateTime initialDate = now;
          // try to parse existing controller text as dd/MM/yyyy
          try {
            final parts = controller.text.split('/');
            if (parts.length == 3) {
              final d = int.parse(parts[0]);
              final m = int.parse(parts[1]);
              final y = int.parse(parts[2]);
              initialDate = DateTime(y, m, d);
            }
          } catch (_) {}
          final picked = await showDatePicker(
            context: context,
            initialDate: initialDate,
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            controller.text =
                '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
          }
        },
      ),
    );
  }
}
