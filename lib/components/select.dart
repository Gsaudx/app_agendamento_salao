import 'package:flutter/material.dart';

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

  void _mostrarBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _SelectBottomSheet<T>(
        items: items,
        value: value,
        onChanged: (valor) {
          Navigator.pop(context);
          onChanged?.call(valor);
        },
        label: label,
        itemLabel: itemLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textoSelecionado = value != null
        ? (itemLabel?.call(value as T) ?? value.toString())
        : null;

    return Container(
      margin: margin ?? const EdgeInsets.all(8.0),
      child: FormField<T>(
        initialValue: value,
        validator: validator,
        builder: (state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: enabled ? () => _mostrarBottomSheet(context) : null,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: label,
                    hintText: placeholder,
                    prefixIcon: prefixIcon,
                    contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCF7072), width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    errorText: state.errorText,
                    suffixIcon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey[600],
                    ),
                  ),
                  child: Text(
                    textoSelecionado ?? placeholder ?? '',
                    style: TextStyle(
                      color: textoSelecionado != null ? Colors.black87 : Colors.grey[500],
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SelectBottomSheet<T> extends StatelessWidget {
  final List<T> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String? label;
  final String Function(T item)? itemLabel;

  const _SelectBottomSheet({
    required this.items,
    this.value,
    required this.onChanged,
    this.label,
    this.itemLabel,
  });

  @override
  Widget build(BuildContext context) {
    final alturaMaxima = MediaQuery.of(context).size.height * 0.6;

    return Container(
      constraints: BoxConstraints(maxHeight: alturaMaxima),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (label != null) ...[
            const SizedBox(height: 16),
            Text(
              label!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final selecionado = item == value;
                final texto = itemLabel?.call(item) ?? item.toString();

                return InkWell(
                  onTap: () => onChanged(item),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: selecionado ? const Color(0xFFFEC8C8).withOpacity(0.3) : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            texto,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: selecionado ? FontWeight.w600 : FontWeight.normal,
                              color: selecionado ? const Color(0xFFCF7072) : Colors.black87,
                            ),
                          ),
                        ),
                        if (selecionado)
                          const Icon(
                            Icons.check_rounded,
                            color: Color(0xFFCF7072),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}
