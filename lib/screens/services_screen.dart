import 'package:flutter/material.dart';

import '../components/Input.dart';
import '../components/select.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static const routeName = '/services';

  void _addService(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final durationController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
      return Dialog(
        shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16), bottom: Radius.circular(16)),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(dialogContext).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Adicionar serviço', style: Theme.of(context).textTheme.titleMedium),
              Input(label: 'Nome', controller: nameController, placeholder: 'Digite o nome do serviço'),
              Select<String>(
                label: 'Duração',
                placeholder: 'Selecione a duração',
                items: ['30 min', '45 min', '1h', '1h30', '2h'],
                value: null,
                onChanged: (value) {},
              ),
              Input(label: 'Preço', controller: priceController, placeholder: 'Digite o preço do serviço',),
              const SizedBox(width: 12),
              Row(
              children: [
                Expanded(
                child: OutlinedButton(
                  onPressed: () {
                  Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                ),
                const SizedBox(width: 12),
                Expanded(
                child: FilledButton(
                  onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Serviço adicionado: ${nameController.text}'),
                    ),
                    );
                  }
                  },
                  child: const Text('Salvar'),
                ),
                ),
              ],
              ),
            ],
            ),
          ),
          ),
        ),
        ),
      );
      },
    ).whenComplete(() {
      nameController.dispose();
      durationController.dispose();
      priceController.dispose();
    });
    }

  @override
  Widget build(BuildContext context) {
    final services = [
      (name: 'Corte feminino', duration: '45 min', price: 'R\$ 80'),
      (name: 'Coloração completa', duration: '2h', price: 'R\$ 160'),
      (name: 'Hidratação profunda', duration: '1h', price: 'R\$ 90'),
      (name: 'Manicure e pedicure', duration: '1h30', price: 'R\$ 70'),
      (name: 'Escova modeladora', duration: '50 min', price: 'R\$ 60'),
      (name: 'Penteado festa', duration: '1h30', price: 'R\$ 120'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Serviços'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              onPressed: () {
                _addService(context);
              },
              icon: const Icon(Icons.add),
            ),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Text('Duração: ${service.duration}'),
                  const SizedBox(height: 8),
                  Text('Valor: ${service.price}'),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: const Text('Agendar'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
