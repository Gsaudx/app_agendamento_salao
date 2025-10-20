import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import '../components/Input.dart';
import '../components/select.dart';
import '../dependencias/dependencias_widget.dart';
import '../formatters/moeda_input_formatter.dart';
import '../modelos/servico.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static const routeName = '/services';

  Future<void> _addService(BuildContext context) async {
    final servicosServico = DependenciasWidget.servicosDe(context);
    final nomeController = TextEditingController();
    final precoController = TextEditingController();
    final descricaoController = TextEditingController();
    const duracoesDisponiveis = <int>[30, 45, 60, 90, 120];
    int? duracaoSelecionada;
    bool salvando = false;

    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                  bottom: Radius.circular(16),
                ),
              ),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 40,
              ),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Adicionar serviço',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Input(
                          label: 'Nome',
                          controller: nomeController,
                          placeholder: 'Digite o nome do serviço',
                        ),
                        Select<int>(
                          label: 'Duração',
                          placeholder: 'Selecione a duração',
                          items: duracoesDisponiveis,
                          value: duracaoSelecionada,
                          onChanged: (valor) =>
                              setState(() => duracaoSelecionada = valor),
                          itemLabel: (valor) => _formatarDuracao(valor),
                        ),
                        Input(
                          label: 'Preço',
                          controller: precoController,
                          placeholder: '0,00',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [MoedaInputFormatter()],
                          prefixText: 'R\$ ',
                        ),
                        Input(
                          label: 'Descrição (opcional)',
                          controller: descricaoController,
                          placeholder: 'Resumo rápido do serviço',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: salvando
                                    ? null
                                    : () => Navigator.of(
                                        dialogContext,
                                      ).pop(false),
                                child: const Text('Cancelar'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: salvando
                                    ? null
                                    : () async {
                                        final nome = nomeController.text.trim();
                                        final preco =
                                            MoedaInputFormatter.toDouble(
                                              precoController.text,
                                            ) ??
                                            -1;
                                        if (nome.isEmpty ||
                                            duracaoSelecionada == null ||
                                            preco < 0) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Informe nome, duração e um preço válido.',
                                              ),
                                            ),
                                          );
                                          return;
                                        }
                                        setState(() => salvando = true);
                                        try {
                                          await servicosServico.criarServico(
                                            nome: nome,
                                            duracaoMinutos: duracaoSelecionada!,
                                            preco: preco,
                                            descricao:
                                                descricaoController.text
                                                    .trim()
                                                    .isEmpty
                                                ? null
                                                : descricaoController.text
                                                      .trim(),
                                          );
                                          if (context.mounted) {
                                            Navigator.of(
                                              dialogContext,
                                            ).pop(true);
                                          }
                                        } catch (erro) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Não foi possível salvar: $erro',
                                                ),
                                              ),
                                            );
                                          }
                                          setState(() => salvando = false);
                                        }
                                      },
                                child: salvando
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Salvar'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    nomeController.dispose();
    precoController.dispose();
    descricaoController.dispose();

    if (resultado == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Serviço cadastrado com sucesso.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicosServico = DependenciasWidget.servicosDe(context);
    final formatadorMoeda = NumberFormat.simpleCurrency(locale: 'pt_BR');

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
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatarDuracao(int minutos) {
    if (minutos % 60 == 0) {
      final horas = minutos ~/ 60;
      return horas == 1 ? '1 hora' : '$horas horas';
    }
    final horas = minutos ~/ 60;
    final restante = minutos % 60;
    if (horas == 0) {
      return '$restante minutos';
    }
    return '${horas}h${restante.toString().padLeft(2, '0')}';
  }
}
