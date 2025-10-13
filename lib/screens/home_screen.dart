import 'package:flutter/material.dart';

import 'appointments_screen.dart';
import 'clients_screen.dart';
import 'services_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda do Salão'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          Text(
            'Bem-vinda, Paula!',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          _DashboardCard(
            icon: Icons.calendar_month,
            title: 'Próximos agendamentos',
            description: 'Ver compromissos confirmados para hoje e amanhã.',
            onTap: () => Navigator.pushNamed(context, AppointmentsScreen.routeName),
          ),
          _DashboardCard(
            icon: Icons.people_alt,
            title: 'Clientes',
            description: 'Listar contatos frequentes e preferências.',
            onTap: () => Navigator.pushNamed(context, ClientsScreen.routeName),
          ),
          _DashboardCard(
            icon: Icons.cut,
            title: 'Serviços',
            description: 'Consultar valores e tempo de cada atendimento.',
            onTap: () => Navigator.pushNamed(context, ServicesScreen.routeName),
          ),
          const SizedBox(height: 32),
          Text(
            'Resumo do dia',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ..._buildTodaySchedule(theme),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Novo agendamento'),
      ),
    );
  }

  List<Widget> _buildTodaySchedule(ThemeData theme) {
    final items = [
      (time: '09:00', client: 'Ana Ferreira', service: 'Corte feminino'),
      (time: '11:30', client: 'Bruna Souza', service: 'Coloração'),
      (time: '15:00', client: 'Maria Silva', service: 'Manicure e pedicure'),
    ];

    return items
        .map(
          (item) => Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                child: Text(item.time.replaceAll(':00', 'h')),
              ),
              title: Text(item.client),
              subtitle: Text(item.service),
              trailing: IconButton(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () {},
              ),
            ),
          ),
        )
        .toList();
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                child: Icon(icon, size: 26),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
