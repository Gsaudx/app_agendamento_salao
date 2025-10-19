import 'package:flutter/material.dart';

class NewClientScreen extends StatelessWidget {
  const NewClientScreen({super.key});

  static const routeName = '/new-client';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Cliente'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Nome',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Telefone',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Notas',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Lógica para salvar o novo cliente
            },
            child: const Text('Salvar Cliente'),
          ),
        ],
      ),
    );
  }
}