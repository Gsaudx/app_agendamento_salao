import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/app_bar_padrao.dart';
import '../components/floating_menu.dart';
import '../dependencias/dependencias_widget.dart';
import '../modelos/agendamento.dart';
import '../modelos/cliente.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  static const routeName = '/history';

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime? _dataInicial;
  DateTime? _dataFinal;
  Cliente? _clienteSelecionado;
  final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  Widget build(BuildContext context) {
    final agendamentosServico = DependenciasWidget.agendamentosDe(context);
    final clientesServico = DependenciasWidget.clientesDe(context);

    return Scaffold(
      appBar: const AppBarPadrao(),
      body: Column(
        children: [
          // Filters Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Client Search
                StreamBuilder<List<Cliente>>(
                  stream: clientesServico.observarClientes(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const LinearProgressIndicator();
                    }
                    final clientes = snapshot.data!;

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return Autocomplete<Cliente>(
                          displayStringForOption: (Cliente option) => option.nome,
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return const Iterable<Cliente>.empty();
                            }
                            return clientes.where((Cliente option) {
                              return option.nome.toLowerCase().contains(
                                    textEditingValue.text.toLowerCase(),
                                  );
                            });
                          },
                          onSelected: (Cliente selection) {
                            setState(() {
                              _clienteSelecionado = selection;
                            });
                          },
                          fieldViewBuilder: (
                            context,
                            textEditingController,
                            focusNode,
                            onFieldSubmitted,
                          ) {
                            // If a client is selected, show their name in the controller
                            if (_clienteSelecionado != null &&
                                textEditingController.text !=
                                    _clienteSelecionado!.nome) {
                              textEditingController.text =
                                  _clienteSelecionado!.nome;
                            }

                            return TextField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search),
                                hintText: 'Buscar por Cliente...',
                                filled: true,
                                fillColor: Colors.grey[100],
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: _clienteSelecionado != null
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          setState(() {
                                            _clienteSelecionado = null;
                                            textEditingController.clear();
                                          });
                                        },
                                      )
                                    : const Icon(Icons.filter_list),
                              ),
                            );
                          },
                          optionsViewBuilder: (
                            context,
                            onSelected,
                            options,
                          ) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                child: SizedBox(
                                  width: constraints.maxWidth,
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      final Cliente option =
                                          options.elementAt(index);
                                      return ListTile(
                                        title: Text(option.nome),
                                        onTap: () {
                                          onSelected(option);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Date Range
                Row(
                  children: [
                    const Text(
                      'Período: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DateFilterButton(
                        label: 'Inicial',
                        selectedDate: _dataInicial,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _dataInicial ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              _dataInicial = picked;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DateFilterButton(
                        label: 'Final',
                        selectedDate: _dataFinal,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _dataFinal ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              _dataFinal = picked;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_clienteSelecionado != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Cliente: ${_clienteSelecionado!.nome}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          const Divider(),
          // List Content
          Expanded(
            child: StreamBuilder<List<Agendamento>>(
              stream: agendamentosServico.observarHistorico(
                inicio: _dataInicial,
                fim: _dataFinal,
                clienteId: _clienteSelecionado?.id,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  debugPrint('Erro no histórico: ${snapshot.error}');
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SelectableText(
                        'Erro: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final agendamentos = snapshot.data ?? [];
                
                if (agendamentos.isEmpty) {
                  return const Center(
                    child: Text('Nenhum agendamento encontrado.'),
                  );
                }

                if (_clienteSelecionado != null) {
                  return _buildClientHistoryList(agendamentos);
                } else {
                  return _buildGeneralHistoryList(agendamentos);
                }
              },
            ),
          ),
          // Total Footer
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: StreamBuilder<List<Agendamento>>(
              stream: agendamentosServico.observarHistorico(
                inicio: _dataInicial,
                fim: _dataFinal,
                clienteId: _clienteSelecionado?.id,
              ),
              builder: (context, snapshot) {
                final total = (snapshot.data ?? []).fold<double>(
                  0,
                  (sum, item) => sum + item.total,
                );
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Valor total:',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      _currencyFormat.format(total),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const FloatingMenu(currentRoute: HistoryScreen.routeName),
    );
  }

  Widget _buildGeneralHistoryList(List<Agendamento> agendamentos) {
    // Group by date
    final Map<String, List<Agendamento>> grouped = {};
    for (var agendamento in agendamentos) {
      final dateKey = DateFormat('yyyy-MM-dd').format(agendamento.inicio);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(agendamento);
    }

    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Descending

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final dateKey = sortedKeys[index];
        final dailyAppointments = grouped[dateKey]!;
        final date = DateTime.parse(dateKey);
        final dailyTotal = dailyAppointments.fold<double>(
          0,
          (sum, item) => sum + item.total,
        );

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Column
              SizedBox(
                width: 50,
                child: Column(
                  children: [
                    Text(
                      DateFormat('dd').format(date),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('MMM', 'pt_BR').format(date),
                      style: const TextStyle(fontSize: 14),
                    ),
                    Expanded(
                      child: Container(
                        width: 1,
                        color: Colors.grey[300],
                        margin: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Appointments Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...dailyAppointments.map((agendamento) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    agendamento.descricaoServicos,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    agendamento.clienteNome,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _currencyFormat.format(agendamento.total),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Valor do dia',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        Text(
                          _currencyFormat.format(dailyTotal),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClientHistoryList(List<Agendamento> agendamentos) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: agendamentos.length,
      itemBuilder: (context, index) {
        final agendamento = agendamentos[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: _clienteSelecionado?.fotoUrl != null
                      ? NetworkImage(_clienteSelecionado!.fotoUrl!)
                      : null,
                  child: _clienteSelecionado?.fotoUrl == null
                      ? const Icon(Icons.person, size: 30)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            agendamento.clienteNome,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            DateFormat('dd/MM/yyyy').format(agendamento.inicio),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Procedimento(s): ${agendamento.descricaoServicos}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      if (agendamento.observacoes != null &&
                          agendamento.observacoes!.isNotEmpty)
                        Text(
                          'Observação: ${agendamento.observacoes}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        'Valor: ${_currencyFormat.format(agendamento.total)}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Início: ${DateFormat('HH:mm').format(agendamento.inicio)}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          if (agendamento.fim != null)
                            Text(
                              'Fim: ${DateFormat('HH:mm').format(agendamento.fim!)}',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DateFilterButton extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final VoidCallback onTap;

  const _DateFilterButton({
    required this.label,
    required this.selectedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate != null
                  ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                  : label,
              style: TextStyle(
                color: selectedDate != null ? Colors.black : Colors.grey,
              ),
            ),
            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
