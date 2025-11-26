import 'package:flutter/material.dart';

/// Select component usado como um DropdownFormField reutilizável.
/// Tipo genérico T permite usar qualquer tipo de dado como value.
class Select<T> extends StatelessWidget {
  final List<T> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String? placeholder;
  final bool isExpanded;
  final bool enabled;
  final Widget? prefixIcon;
  final FormFieldValidator<T?>? validator;
  final String Function(T item)? itemLabel;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? margin;

  const Select({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    required this.label,
    required this.placeholder,
    this.isExpanded = true,
    this.enabled = true,
    this.prefixIcon,
    this.validator,
    this.itemLabel,
    this.contentPadding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(8.0),
      child: DropdownButtonFormField<T>(
        key: value == null ? null : ValueKey<T?>(value),
        initialValue: value,
        items: items
            .map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(itemLabel?.call(item) ?? item.toString()),
              ),
            )
            .toList(),
        onChanged: enabled ? onChanged : null,
        isExpanded: isExpanded,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: placeholder,
          prefixIcon: prefixIcon,
          contentPadding: contentPadding,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
        ),
      ),
    );
  }
}
