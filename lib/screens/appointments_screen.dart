import 'package:flutter/material.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  static const routeName = '/appointments';

  @override
  Widget build(BuildContext context) {
    final appointments = [
      (date: '13 out • 09:00', client: 'Ana Ferreira', service: 'Corte feminino', price: 'R\$ 80'),
      (date: '13 out • 11:30', client: 'Bruna Souza', service: 'Coloração', price: 'R\$ 160'),
      (date: '13 out • 15:00', client: 'Maria Silva', service: 'Manicure e pedicure', price: 'R\$ 70'),
      (date: '14 out • 10:00', client: 'Carla Mendes', service: 'Hidratação', price: 'R\$ 55'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamentos'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return Card(
            child: ListTile(
              title: Text(appointment.client),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(appointment.service),
                  const SizedBox(height: 4),
                  Text(appointment.date, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              trailing: Text(
                appointment.price,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              onTap: () {},
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
      ),
    );
  }
}
