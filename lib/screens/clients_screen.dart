import 'package:flutter/material.dart';

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  static const routeName = '/clients';

  @override
  Widget build(BuildContext context) {
    final clients = [
      (name: 'Ana Ferreira', phone: '(11) 99999-1234', notes: 'Prefere produtos veganos'),
      (name: 'Bruna Souza', phone: '(11) 98888-4567', notes: 'Coloração a cada 45 dias'),
      (name: 'Maria Silva', phone: '(11) 97777-8901', notes: 'Sempre agenda manicure nas sextas'),
      (name: 'Carla Mendes', phone: '(11) 96666-2345', notes: 'Cabelo cacheado, gosta de finalização com difusor'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: clients.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final client = clients[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(client.name.substring(0, 1)),
              ),
              title: Text(client.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(client.phone),
                  const SizedBox(height: 4),
                  Text(client.notes),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.message_outlined),
                onPressed: () {},
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Novo cliente'),
      ),
    );
  }
}
