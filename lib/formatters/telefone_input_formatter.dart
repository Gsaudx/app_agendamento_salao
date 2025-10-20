import 'package:flutter/services.dart';

/// Formata automaticamente números de telefone brasileiros enquanto o usuário digita.
class TelefoneInputFormatter extends TextInputFormatter {
  const TelefoneInputFormatter();

  /// Retorna apenas os dígitos de uma string.
  static String digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

  /// Aplica a máscara padrão considerando DDD e 9º dígito quando disponível.
  static String formatValue(String value) {
    final digits = digitsOnly(value);
    if (digits.isEmpty) {
      return '';
    }
    final limited = digits.length > 11 ? digits.substring(0, 11) : digits;
    return _format(limited);
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = TelefoneInputFormatter.digitsOnly(newValue.text);
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final limited = digitsOnly.length > 11
        ? digitsOnly.substring(0, 11)
        : digitsOnly;
    final formatted = _format(limited);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String _format(String digits) {
    if (digits.length <= 2) {
      final buffer = StringBuffer('(')..write(digits);
      if (digits.length == 2) {
        buffer.write(') ');
      }
      return buffer.toString();
    }

    final buffer = StringBuffer()
      ..write('(')
      ..write(digits.substring(0, 2))
      ..write(') ');

    final remainder = digits.substring(2);
    if (remainder.length <= 4) {
      buffer.write(remainder);
      return buffer.toString();
    }

    if (remainder.length <= 8) {
      buffer
        ..write(remainder.substring(0, 4))
        ..write('-')
        ..write(remainder.substring(4));
      return buffer.toString();
    }

    buffer
      ..write(remainder.substring(0, 5))
      ..write('-')
      ..write(remainder.substring(5));
    return buffer.toString();
  }
}
