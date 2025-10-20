import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formata valores monetários enquanto o usuário digita, mantendo centavos.
class MoedaInputFormatter extends TextInputFormatter {
  MoedaInputFormatter({this.locale = 'pt_BR', this.symbol = ''})
    : _formatter = NumberFormat.currency(locale: locale, symbol: symbol);

  final String locale;
  final String symbol;
  final NumberFormat _formatter;

  static String digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

  static double? toDouble(String value) {
    final digits = digitsOnly(value);
    if (digits.isEmpty) {
      return null;
    }
    final cents = double.parse(digits);
    return cents / 100;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = digitsOnly(newValue.text);
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }
    final valor = double.parse(digits) / 100;
    final formatted = _formatter.format(valor);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
