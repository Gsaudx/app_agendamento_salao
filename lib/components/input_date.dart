import 'package:flutter/material.dart';

class InputDate extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final ValueChanged<DateTime>? onDateSelected;

  const InputDate({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.datetime,
    this.onDateSelected,
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
          suffixIcon: Container(
            margin: const EdgeInsets.only(right: 8),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFFCF7072),
            ),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
        ),
        onTap: () => _selecionarData(context),
      ),
    );
  }

  Future<void> _selecionarData(BuildContext context) async {
    final now = DateTime.now();
    DateTime initialDate = now;
    
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFCF7072),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
              secondary: Color(0xFFFEC8C8),
              onSecondary: Color(0xFFCF7072),
            ),
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFCF7072),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              headerBackgroundColor: const Color(0xFFFEC8C8),
              headerForegroundColor: const Color(0xFF5D4037),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFFCF7072);
                }
                return null;
              }),
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return Colors.black87;
              }),
              todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFFCF7072);
                }
                return Colors.transparent;
              }),
              todayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return const Color(0xFFCF7072);
              }),
              todayBorder: const BorderSide(
                color: Color(0xFFCF7072),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              dayStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              yearStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              weekdayStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFCF7072),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      onDateSelected?.call(picked);
    }
  }
}
