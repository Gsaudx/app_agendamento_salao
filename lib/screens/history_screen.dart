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
  bool _filtrosDataExpandidos = false;
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
                const SizedBox(height: 12),
                // Filtros de Data - Expansível
                _buildFiltrosDataExpansiveis(),
              ],
            ),
          ),
          if (_clienteSelecionado != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFFEC8C8),
                    backgroundImage: _clienteSelecionado!.fotoUrl != null
                        ? NetworkImage(_clienteSelecionado!.fotoUrl!)
                        : null,
                    child: _clienteSelecionado!.fotoUrl == null
                        ? Text(
                            _clienteSelecionado!.nome.isNotEmpty
                                ? _clienteSelecionado!.nome[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFCF7072),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Histórico de',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          _clienteSelecionado!.nome,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
    // Agrupa os agendamentos por mês/ano
    final Map<String, List<Agendamento>> agrupadosPorMes = {};
    for (var agendamento in agendamentos) {
      final mesAno = DateFormat('MMMM yyyy', 'pt_BR').format(agendamento.inicio);
      agrupadosPorMes.putIfAbsent(mesAno, () => []).add(agendamento);
    }

    final mesesOrdenados = agrupadosPorMes.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: mesesOrdenados.length,
      itemBuilder: (context, mesIndex) {
        final mesAno = mesesOrdenados[mesIndex];
        final agendamentosDoMes = agrupadosPorMes[mesAno]!;
        final totalMes = agendamentosDoMes.fold<double>(
          0,
          (sum, item) => sum + item.total,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho do mês
            Container(
              margin: const EdgeInsets.only(top: 16, bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCF7072),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      mesAno.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _currencyFormat.format(totalMes),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // Lista de agendamentos do mês
            ...agendamentosDoMes.asMap().entries.map((entry) {
              final index = entry.key;
              final agendamento = entry.value;
              final isLast = index == agendamentosDoMes.length - 1;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline lateral
                    SizedBox(
                      width: 60,
                      child: Column(
                        children: [
                          // Data
                          Container(
                            width: 44,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEC8C8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  DateFormat('dd').format(agendamento.inicio),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFCF7072),
                                  ),
                                ),
                                Text(
                                  DateFormat('EEE', 'pt_BR').format(agendamento.inicio).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Linha conectora
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      const Color(0xFFCF7072).withOpacity(0.5),
                                      const Color(0xFFCF7072).withOpacity(0.1),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Card do agendamento
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header do card com horário
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    DateFormat('HH:mm').format(agendamento.inicio),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  if (agendamento.fim != null) ...[
                                    Text(
                                      ' - ${DateFormat('HH:mm').format(agendamento.fim!)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFCF7072),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _currencyFormat.format(agendamento.total),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Conteúdo do card
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Serviços
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEC8C8),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.content_cut,
                                          size: 18,
                                          color: Color(0xFFCF7072),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              agendamento.descricaoServicos,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (agendamento.observacoes != null &&
                                                agendamento.observacoes!.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 6),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Icon(
                                                      Icons.notes,
                                                      size: 14,
                                                      color: Colors.grey[400],
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        agendamento.observacoes!,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.grey[600],
                                                          fontStyle: FontStyle.italic,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildFiltrosDataExpansiveis() {
    final temFiltroData = _dataInicial != null || _dataFinal != null;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: temFiltroData ? const Color(0xFFCF7072).withOpacity(0.3) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          // Cabeçalho clicável
          InkWell(
            onTap: () {
              setState(() {
                _filtrosDataExpandidos = !_filtrosDataExpandidos;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.date_range,
                    size: 20,
                    color: temFiltroData ? const Color(0xFFCF7072) : Colors.grey[600],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      temFiltroData 
                          ? _formatarPeriodoSelecionado()
                          : 'Filtrar por período',
                      style: TextStyle(
                        color: temFiltroData ? Colors.black87 : Colors.grey[600],
                        fontWeight: temFiltroData ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (temFiltroData)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _dataInicial = null;
                          _dataFinal = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _filtrosDataExpandidos ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Conteúdo expansível
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCampoData(
                          label: 'Data inicial',
                          data: _dataInicial,
                          onTap: () => _selecionarData(isInicial: true),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(
                          Icons.arrow_forward,
                          size: 20,
                          color: Colors.grey[400],
                        ),
                      ),
                      Expanded(
                        child: _buildCampoData(
                          label: 'Data final',
                          data: _dataFinal,
                          onTap: () => _selecionarData(isInicial: false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Atalhos rápidos
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildAtalhoRapido('Hoje', () {
                          final hoje = DateTime.now();
                          setState(() {
                            _dataInicial = DateTime(hoje.year, hoje.month, hoje.day);
                            _dataFinal = DateTime(hoje.year, hoje.month, hoje.day, 23, 59, 59);
                          });
                        }),
                        const SizedBox(width: 8),
                        _buildAtalhoRapido('Esta semana', () {
                          final hoje = DateTime.now();
                          final inicioSemana = hoje.subtract(Duration(days: hoje.weekday - 1));
                          setState(() {
                            _dataInicial = DateTime(inicioSemana.year, inicioSemana.month, inicioSemana.day);
                            _dataFinal = hoje;
                          });
                        }),
                        const SizedBox(width: 8),
                        _buildAtalhoRapido('Este mês', () {
                          final hoje = DateTime.now();
                          setState(() {
                            _dataInicial = DateTime(hoje.year, hoje.month, 1);
                            _dataFinal = hoje;
                          });
                        }),
                        const SizedBox(width: 8),
                        _buildAtalhoRapido('Último mês', () {
                          final hoje = DateTime.now();
                          final mesPassado = DateTime(hoje.year, hoje.month - 1, 1);
                          final fimMesPassado = DateTime(hoje.year, hoje.month, 0);
                          setState(() {
                            _dataInicial = mesPassado;
                            _dataFinal = fimMesPassado;
                          });
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState: _filtrosDataExpandidos 
                ? CrossFadeState.showSecond 
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildCampoData({
    required String label,
    required DateTime? data,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: data != null ? const Color(0xFFCF7072).withOpacity(0.5) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: data != null ? const Color(0xFFCF7072) : Colors.grey[400],
            ),
            const SizedBox(width: 8),
            Text(
              data != null 
                  ? DateFormat('dd/MM/yyyy').format(data)
                  : label,
              style: TextStyle(
                color: data != null ? Colors.black87 : Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAtalhoRapido(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFEC8C8).withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFFCF7072),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _formatarPeriodoSelecionado() {
    final formato = DateFormat('dd/MM/yyyy');
    if (_dataInicial != null && _dataFinal != null) {
      return '${formato.format(_dataInicial!)} - ${formato.format(_dataFinal!)}';
    } else if (_dataInicial != null) {
      return 'A partir de ${formato.format(_dataInicial!)}';
    } else if (_dataFinal != null) {
      return 'Até ${formato.format(_dataFinal!)}';
    }
    return '';
  }

  Future<void> _selecionarData({required bool isInicial}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isInicial 
          ? (_dataInicial ?? DateTime.now())
          : (_dataFinal ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFCF7072),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isInicial) {
          _dataInicial = picked;
        } else {
          _dataFinal = picked;
        }
      });
    }
  }
}
