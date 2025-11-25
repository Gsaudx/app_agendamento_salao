import 'package:flutter/material.dart';

import '../components/floating_button.dart';
import '../components/floating_menu.dart';
import '../dependencias/dependencias_widget.dart';
import '../formatters/telefone_input_formatter.dart';
import '../modelos/cliente.dart';
import 'editclient_screen.dart';
import 'newclient_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  static const routeName = '/history';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      appBar: AppBar(
        title: const Text('Histórico'),
        backgroundColor: const Color.fromARGB(255, 252, 218, 218),
      ),
      body: ListView.builder(
        itemCount: 4, // Número de exemplo de itens na lista
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              title: Text('Cliente ${index + 1}'),
              subtitle: const Text('Serviço realizado - Data'),
              trailing: const Text('R\$ 100,00'),
            ),
          );
        },
      ),
      bottomNavigationBar: const FloatingMenu(currentRoute: routeName),
    );
  }
}
