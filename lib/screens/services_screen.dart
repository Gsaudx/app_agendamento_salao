import 'package:app_paula_barros/components/floating_button.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import '../components/app_bar_padrao.dart';
import '../components/floating_menu.dart';
import '../modelos/servico.dart';
import '../dependencias/dependencias_widget.dart';
import 'editservice_screen.dart';
import 'newservice_screen.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static const routeName = '/services';

  Future<void> _abrirCadastroServico(BuildContext context) async {
    final resultado = await Navigator.pushNamed(
      context,
      NewServiceScreen.routeName,
    );
    if (resultado == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Serviço cadastrado com sucesso.')),
      );
    }
  }

  Future<void> _editarServico(BuildContext context, Servico servico) async {
    final resultado = await Navigator.pushNamed(
      context,
      EditServiceScreen.routeName,
      arguments: servico,
    );
    if (resultado == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Serviço atualizado com sucesso.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicosServico = DependenciasWidget.servicosDe(context);
    final formatadorMoeda = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return Scaffold(
      appBar: const AppBarPadrao(),
      body: StreamBuilder<List<Servico>>(
        stream: servicosServico.observarServicos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Erro ao carregar serviços:\n${snapshot.error}'),
              ),
            );
          }
          final servicos = snapshot.data ?? const <Servico>[];
          if (servicos.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Nenhum serviço cadastrado ainda. Adicione o primeiro usando o botão acima.',
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: servicos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final servico = servicos[index];
              final precoFormatado = formatadorMoeda.format(servico.preco);
              final theme = Theme.of(context);
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        foregroundColor: theme.colorScheme.onPrimaryContainer,
                        child: const Icon(Icons.cut, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              servico.nome,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Chip(
                                  label: Text(servico.duracaoFormatada),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                            if (servico.descricao?.isNotEmpty == true) ...[
                              const SizedBox(height: 8),
                              Text(
                                servico.descricao!,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            precoFormatado,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              FilledButton.tonalIcon(
                                onPressed: () => _editarServico(context, servico),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                label: const Text('Editar'),
                              ),
                              const SizedBox(width: 8),
                              FilledButton.tonalIcon(
                                onPressed: () {},
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                                icon: const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 18,
                                ),
                                label: const Text('Agendar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const FloatingMenu(currentRoute: ServicesScreen.routeName),
      floatingActionButton: FloatingButton(
        label: 'Novo Serviço',
        onPressed: () => _abrirCadastroServico(context),
      ),
    );
  }
}
