import 'package:flutter/material.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static const routeName = '/services';

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
