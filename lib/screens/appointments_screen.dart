import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../dependencias/dependencias_widget.dart';
import '../modelos/agendamento.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  static const routeName = '/appointments';

  @override
  Widget build(BuildContext context) {
    final agendamentosServico = DependenciasWidget.agendamentosDe(context);
    final formatadorData = DateFormat.MMMd('pt_BR');
    final formatadorHora = DateFormat.Hm('pt_BR');
    final formatadorMoeda = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return Scaffold(
      appBar: AppBar(title: const Text('Agendamentos')),
      body: StreamBuilder<List<Agendamento>>(
        stream: agendamentosServico.observarAgenda(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Erro ao carregar agenda:\n${snapshot.error}'),
              ),
            );
          }
          final agendamentos = snapshot.data ?? const <Agendamento>[];
          if (agendamentos.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Nenhum agendamento futuro encontrado.'),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: agendamentos.length,
            itemBuilder: (context, index) {
              final agendamento = agendamentos[index];
              final dataFormatada =
                  '${formatadorData.format(agendamento.inicio)} • ${formatadorHora.format(agendamento.inicio)}';
              final precoFormatado = agendamento.preco != null
                  ? formatadorMoeda.format(agendamento.preco)
                  : '—';
              return Card(
                child: ListTile(
                  title: Text(agendamento.clienteNome),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(agendamento.servicoNome),
                      const SizedBox(height: 4),
                      Text(
                        dataFormatada,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  trailing: Text(
                    precoFormatado,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {},
                ),
              );
            },
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
