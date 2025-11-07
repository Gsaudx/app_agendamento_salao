import 'package:app_paula_barros/screens/newappointmens_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../dependencias/dependencias_widget.dart';
import '../modelos/agendamento.dart';
import '../servicos/agendamentos_servico.dart';
import '../servicos/autenticacao_servico.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AutenticacaoServico _autenticacao;
  late final AgendamentosServico _agendamentosServico;
  late final TextEditingController _buscaController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateUtils.dateOnly(DateTime.now());
  String _visaoSelecionada = _VisaoCalendario.mes;

  @override
  void initState() {
    super.initState();
    _buscaController = TextEditingController()
      ..addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _autenticacao = DependenciasWidget.autenticacaoDe(context);
    _agendamentosServico = DependenciasWidget.agendamentosDe(context);
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usuario = _autenticacao.usuarioAtual;
    final saudacao = _nomeParaSaudacao(usuario);
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda do Salão'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            onPressed: () => _sair(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: StreamBuilder<List<Agendamento>>(
          stream: _agendamentosServico.observarAgenda(apenasFuturos: false),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Falha ao carregar agendamentos.\n${snapshot.error}',
                  ),
                ),
              );
            }
            final agendamentos = snapshot.data ?? const <Agendamento>[];
            final eventosPorDia = _organizarPorDia(agendamentos);
            final selecionados =
                eventosPorDia[_selectedDay] ?? const <Agendamento>[];
            final filtrados = _aplicarFiltro(selecionados);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bem-vindo(a), $saudacao!',
                  style: tema.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Controle seus agendamentos com facilidade.',
                  style: tema.textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _buscaController,
                  decoration: InputDecoration(
                    hintText: 'Busca por cliente, serviço ou observação',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _SegmentedPeriodSelector(
                  visaoSelecionada: _visaoSelecionada,
                  onChange: _alterarVisao,
                ),
                const SizedBox(height: 16),
                TableCalendar<Agendamento>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2035, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: _calendarFormat,
                  availableGestures: AvailableGestures.horizontalSwipe,
                  eventLoader: (day) =>
                      eventosPorDia[DateUtils.dateOnly(day)] ?? const [],
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = DateUtils.dateOnly(selected);
                      _focusedDay = focused;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() => _calendarFormat = format);
                  },
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      if (events.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return _IndicadoresAgendamento(
                        eventos: events.cast<Agendamento>(),
                      );
                    },
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextFormatter: (date, locale) =>
                        DateFormat.yMMMM('pt_BR').format(date),
                    leftChevronIcon: const Icon(Icons.chevron_left),
                    rightChevronIcon: const Icon(Icons.chevron_right),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekendStyle:
                        (tema.textTheme.bodySmall ?? const TextStyle())
                            .copyWith(color: tema.colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: filtrados.isEmpty
                      ? _ListaVazia(selectedDay: _selectedDay)
                      : _ListaAgendamentos(
                          agendamentos: filtrados,
                          onTap: _mostrarDetalhes,
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirNovoAgendamento,
        icon: const Icon(Icons.add),
        label: const Text('Novo agendamento'),
      ),
    );
  }

  Map<DateTime, List<Agendamento>> _organizarPorDia(
    List<Agendamento> agendamentos,
  ) {
    final mapa = <DateTime, List<Agendamento>>{};
    for (final agendamento in agendamentos) {
      final dia = DateUtils.dateOnly(agendamento.inicio);
      mapa.putIfAbsent(dia, () => <Agendamento>[]).add(agendamento);
    }
    for (final entrada in mapa.entries) {
      entrada.value.sort((a, b) => a.inicio.compareTo(b.inicio));
    }
    return mapa;
  }

  List<Agendamento> _aplicarFiltro(List<Agendamento> agendamentos) {
    final termo = _buscaController.text.trim().toLowerCase();
    if (termo.isEmpty) {
      return agendamentos;
    }
    return agendamentos.where((agendamento) {
      final cliente = agendamento.clienteNome.toLowerCase();
      final servicos = agendamento.descricaoServicos.toLowerCase();
      final observacoes = agendamento.observacoes?.toLowerCase() ?? '';
      return cliente.contains(termo) ||
          servicos.contains(termo) ||
          observacoes.contains(termo);
    }).toList();
  }

  void _alterarVisao(String visao) {
    setState(() {
      _visaoSelecionada = visao;
      switch (visao) {
        case _VisaoCalendario.dia:
          _calendarFormat = CalendarFormat.week;
          break;
        case _VisaoCalendario.semana:
          _calendarFormat = CalendarFormat.week;
          break;
        default:
          _calendarFormat = CalendarFormat.month;
      }
    });
  }

  void _abrirNovoAgendamento() {
    final dia = _selectedDay;
    final agora = TimeOfDay.now();
    final horaInicial = DateUtils.isSameDay(dia, DateTime.now())
        ? _alinharParaGrade(agora)
        : const TimeOfDay(hour: 9, minute: 0);
    Navigator.pushNamed(
      context,
      NewAppointmentScreen.routeName,
      arguments: NewAppointmentScreenArguments(
        dia: dia,
        horaInicial: horaInicial,
      ),
    );
  }

  TimeOfDay _alinharParaGrade(TimeOfDay hora) {
    final totalMinutos = hora.hour * 60 + hora.minute;
    const inicio = 6 * 60;
    const fim = 23 * 60 + 59;
    final limitado = totalMinutos < inicio
        ? inicio
        : totalMinutos > fim
        ? fim
        : totalMinutos;
    final alinhado = limitado - (limitado % 15);
    final horas = alinhado ~/ 60;
    final minutos = alinhado % 60;
    return TimeOfDay(hour: horas, minute: minutos);
  }

  void _mostrarDetalhes(Agendamento agendamento) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final tema = Theme.of(context);
        final formatadorHora = DateFormat.Hm('pt_BR');
        final formatadorData = DateFormat.yMMMMd('pt_BR');
        final formatadorMoeda = NumberFormat.simpleCurrency(locale: 'pt_BR');
        final horaInicio = formatadorHora.format(agendamento.inicio);
        final horaFim = formatadorHora.format(
          agendamento.fim ??
              agendamento.inicio.add(
                Duration(minutes: agendamento.duracaoMinutos),
              ),
        );
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                agendamento.clienteNome,
                style: tema.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(formatadorData.format(agendamento.inicio)),
              Text('$horaInicio - $horaFim'),
              const SizedBox(height: 8),
              Text(
                agendamento.descricaoServicos,
                style: tema.textTheme.bodyMedium,
              ),
              if (agendamento.observacoes?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(agendamento.observacoes!, style: tema.textTheme.bodySmall),
              ],
              const SizedBox(height: 12),
              Text(
                formatadorMoeda.format(agendamento.total),
                style: tema.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Edição de agendamento ainda não disponível.',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Editar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Cancelamento de agendamento ainda não disponível.',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Cancelar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _sair(BuildContext context) async {
    final navigator = Navigator.of(context);
    final mensageiro = ScaffoldMessenger.of(context);
    try {
      await _autenticacao.sair();
      navigator.pushNamedAndRemoveUntil(LoginScreen.routeName, (_) => false);
    } catch (erro) {
      mensageiro.showSnackBar(
        SnackBar(content: Text('Não foi possível sair: $erro')),
      );
    }
  }
}

class _IndicadoresAgendamento extends StatelessWidget {
  const _IndicadoresAgendamento({required this.eventos});

  final List<Agendamento> eventos;

  static const _cores = <Color>[
    Color(0xFFCF7072),
    Color(0xFFF2AA4C),
    Color(0xFF9C89B8),
    Color(0xFF5A9E8F),
    Color(0xFF4D6CFA),
    Color(0xFFEF476F),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 34, right: 2, left: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(eventos.length, (index) {
          final cor = _cores[index % _cores.length];
          return Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
          );
        }),
      ),
    );
  }
}

class _ListaAgendamentos extends StatelessWidget {
  const _ListaAgendamentos({required this.agendamentos, required this.onTap});

  final List<Agendamento> agendamentos;
  final ValueChanged<Agendamento> onTap;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final formatadorHora = DateFormat.Hm('pt_BR');
    final formatadorMoeda = NumberFormat.simpleCurrency(locale: 'pt_BR');
    return ListView.separated(
      itemCount: agendamentos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final agendamento = agendamentos[index];
        final horaInicio = formatadorHora.format(agendamento.inicio);
        final horaFim = formatadorHora.format(
          agendamento.fim ??
              agendamento.inicio.add(
                Duration(minutes: agendamento.duracaoMinutos),
              ),
        );
        return Card(
          child: ListTile(
            title: Text(agendamento.clienteNome),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('$horaInicio - $horaFim'),
                const SizedBox(height: 4),
                Text(
                  agendamento.descricaoServicos,
                  style: tema.textTheme.bodySmall,
                ),
              ],
            ),
            trailing: Text(
              formatadorMoeda.format(agendamento.total),
              style: tema.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => onTap(agendamento),
          ),
        );
      },
    );
  }
}

class _ListaVazia extends StatelessWidget {
  const _ListaVazia({required this.selectedDay});

  final DateTime selectedDay;

  @override
  Widget build(BuildContext context) {
    final dataFormatada = DateFormat.yMMMMd('pt_BR').format(selectedDay);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Nenhum agendamento em $dataFormatada. Que tal adicionar um?',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _SegmentedPeriodSelector extends StatelessWidget {
  const _SegmentedPeriodSelector({
    required this.visaoSelecionada,
    required this.onChange,
  });

  final String visaoSelecionada;
  final ValueChanged<String> onChange;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(value: _VisaoCalendario.dia, label: Text('Dia')),
          ButtonSegment(value: _VisaoCalendario.semana, label: Text('Semana')),
          ButtonSegment(value: _VisaoCalendario.mes, label: Text('Mês')),
        ],
        selected: <String>{visaoSelecionada},
        onSelectionChanged: (selecionados) {
          if (selecionados.isNotEmpty) {
            onChange(selecionados.first);
          }
        },
      ),
    );
  }
}

class _VisaoCalendario {
  static const dia = 'dia';
  static const semana = 'semana';
  static const mes = 'mes';
}

String _nomeParaSaudacao(User? usuario) {
  final displayName = usuario?.displayName?.trim();
  if (displayName != null && displayName.isNotEmpty) {
    return _capitalizarCadaPalavra(displayName);
  }

  final email = usuario?.email;
  if (email != null && email.isNotEmpty) {
    final localPart = email.split('@').first.replaceAll(RegExp(r'[._]'), ' ');
    return _capitalizarCadaPalavra(localPart);
  }

  return 'por aqui';
}

String _capitalizarCadaPalavra(String texto) {
  final palavras = texto.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  return palavras
      .map(
        (palavra) => palavra.length == 1
            ? palavra.toUpperCase()
            : '${palavra[0].toUpperCase()}${palavra.substring(1).toLowerCase()}',
      )
      .join(' ');
}
