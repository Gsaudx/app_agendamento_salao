import 'dart:ui' as ui;

import 'package:app_paula_barros/screens/newappointmens_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../components/app_bar_padrao.dart';
import '../components/dialog_confirmacao.dart';
import '../components/floating_menu.dart';
import '../dependencias/dependencias_widget.dart';
import '../modelos/agendamento.dart';
import '../servicos/agendamentos_servico.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AgendamentosServico _agendamentosServico;
  final String _termoBusca = '';
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateUtils.dateOnly(DateTime.now());
  bool _diaExpandido = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _agendamentosServico = DependenciasWidget.agendamentosDe(context);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBarPadrao(
        leading: _diaExpandido
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _voltarParaCalendario,
              )
            : null,
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

            if (_diaExpandido) {
              return _buildVisaoDiaExpandido(
                tema,
                eventosPorDia,
                filtrados,
              );
            }

            return _buildVisaoCalendario(
              tema,
              eventosPorDia,
              filtrados,
            );
          },
        ),
      ),
      bottomNavigationBar:
          const FloatingMenu(currentRoute: HomeScreen.routeName),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirNovoAgendamento,
        icon: const Icon(Icons.add),
        label: const Text('Novo agendamento'),
      ),
    );
  }

  Widget _buildVisaoCalendario(
    ThemeData tema,
    Map<DateTime, List<Agendamento>> eventosPorDia,
    List<Agendamento> filtrados,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final alturaTotal = constraints.maxHeight;
        
        const alturaCabecalho = 50.0;
        const alturaDiasSemana = 24.0;
        const linhasCalendario = 6;
        final alturaCorpo = alturaTotal - alturaCabecalho - alturaDiasSemana;
        final rowHeight = (alturaCorpo / linhasCalendario).clamp(40.0, 90.0);

        return SizedBox(
          height: alturaTotal,
          child: TableCalendar<Agendamento>(
            locale: 'pt_BR',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2035, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: CalendarFormat.month,
            availableGestures: AvailableGestures.horizontalSwipe,
            eventLoader: (day) =>
                eventosPorDia[DateUtils.dateOnly(day)] ?? const [],
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = DateUtils.dateOnly(selected);
                _focusedDay = focused;
                _diaExpandido = true;
              });
              _scrollParaHoraAtual();
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
              defaultBuilder: (context, day, focusedDay) {
                final isWeekend = day.weekday == DateTime.saturday ||
                    day.weekday == DateTime.sunday;
                return _DiaCalendario(
                  dia: day.day,
                  corTexto:
                      isWeekend ? const Color(0xFFCF7072) : Colors.black87,
                );
              },
              todayBuilder: (context, day, focusedDay) {
                final estaSelecionado = isSameDay(_selectedDay, day);
                if (estaSelecionado) {
                  return _DiaCalendario(
                    dia: day.day,
                    corFundo: const Color(0xFFCF7072),
                    corTexto: Colors.white,
                    negrito: true,
                  );
                }
                return _DiaCalendario(
                  dia: day.day,
                  corTexto: const Color(0xFFCF7072),
                  negrito: true,
                );
              },
              selectedBuilder: (context, day, focusedDay) {
                return _DiaCalendario(
                  dia: day.day,
                  corFundo: const Color(0xFFCF7072),
                  corTexto: Colors.white,
                  negrito: true,
                );
              },
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              headerPadding: const EdgeInsets.only(bottom: 8),
              titleTextFormatter: (date, locale) =>
                  DateFormat.yMMMM('pt_BR').format(date),
              titleTextStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              leftChevronIcon: const Icon(Icons.chevron_left, size: 28),
              rightChevronIcon: const Icon(Icons.chevron_right, size: 28),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              weekendStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFFCF7072),
              ),
            ),
            daysOfWeekHeight: 24,
            rowHeight: rowHeight,
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              tablePadding: EdgeInsets.zero,
              cellMargin: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVisaoDiaExpandido(
    ThemeData tema,
    Map<DateTime, List<Agendamento>> eventosPorDia,
    List<Agendamento> agendamentosDoDia,
  ) {
    final dataFormatada = DateFormat.yMMMMEEEEd('pt_BR').format(_selectedDay);

    return Column(
      children: [
        SizedBox(
          height: 110,
          child: TableCalendar<Agendamento>(
            locale: 'pt_BR',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2035, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: CalendarFormat.week,
            availableGestures: AvailableGestures.horizontalSwipe,
            headerVisible: false,
            daysOfWeekHeight: 24,
            rowHeight: 56,
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = DateUtils.dateOnly(selected);
                _focusedDay = focused;
              });
              _scrollParaHoraAtual();
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                return _DiaCalendarioCompacto(
                  dia: day,
                  selecionado: false,
                  hoje: isSameDay(day, DateTime.now()),
                );
              },
              todayBuilder: (context, day, focusedDay) {
                final estaSelecionado = isSameDay(_selectedDay, day);
                return _DiaCalendarioCompacto(
                  dia: day,
                  selecionado: estaSelecionado,
                  hoje: true,
                );
              },
              selectedBuilder: (context, day, focusedDay) {
                return _DiaCalendarioCompacto(
                  dia: day,
                  selecionado: true,
                  hoje: isSameDay(day, DateTime.now()),
                );
              },
            ),
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: true,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            dataFormatada,
            style: tema.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _GradeHorarios(
            scrollController: _scrollController,
            agendamentos: agendamentosDoDia,
            diaSelecionado: _selectedDay,
            onAgendamentoTap: _mostrarDetalhes,
          ),
        ),
      ],
    );
  }

  void _voltarParaCalendario() {
    setState(() {
      _diaExpandido = false;
    });
  }

  void _scrollParaHoraAtual() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final agora = DateTime.now();
      final horaAtual = agora.hour;
      const alturaHora = 60.0;
      const paddingTopo = 20.0;
      final offset = (horaAtual * alturaHora) + paddingTopo - 100;
      _scrollController.animateTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
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
    final termo = _termoBusca.toLowerCase();
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

  Future<void> _editarAgendamento(Agendamento agendamento) async {
    final resultado = await Navigator.pushNamed(
      context,
      NewAppointmentScreen.routeName,
      arguments: NewAppointmentScreenArguments(agendamento: agendamento),
    );
    if (!mounted) {
      return;
    }
    if (resultado == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agendamento atualizado com sucesso.')),
      );
    }
  }

  Future<void> _cancelarAgendamento(Agendamento agendamento) async {
    final formatadorData = DateFormat.yMMMMd('pt_BR');
    final formatadorHora = DateFormat.Hm('pt_BR');
    final confirmado = await DialogConfirmacao.mostrar(
      context: context,
      titulo: 'Cancelar agendamento',
      mensagem: 'Deseja cancelar o agendamento de ${agendamento.clienteNome} em '
          '${formatadorData.format(agendamento.inicio)} às '
          '${formatadorHora.format(agendamento.inicio)}?\n\nEssa ação não pode ser desfeita.',
      tipo: TipoDialogo.confirmacao,
      textoBotaoConfirmar: 'Cancelar',
      textoBotaoCancelar: 'Manter',
    );

    if (!confirmado || !mounted) {
      return;
    }

    final navigator = Navigator.of(context, rootNavigator: true);
    navigator.push(
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) =>
            const Center(child: CircularProgressIndicator()),
        barrierColor: Colors.black26,
        opaque: false,
      ),
    );

    try {
      await _agendamentosServico.cancelarAgendamento(agendamento.id);
      if (navigator.canPop()) {
        navigator.pop();
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agendamento cancelado com sucesso.')),
      );
    } catch (erro) {
      if (navigator.canPop()) {
        navigator.pop();
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível cancelar o agendamento: $erro'),
        ),
      );
    }
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
                        _editarAgendamento(agendamento);
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
                        _cancelarAgendamento(agendamento);
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
    if (eventos.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final alturaTotal = constraints.maxHeight;
        final alturaNumeroDia = 34.0; // espaço para o número do dia
        final alturaDisponivel = alturaTotal - alturaNumeroDia;
        
        if (alturaDisponivel <= 0) return const SizedBox.shrink();
        
        // Calcula quantas barras cabem (cada barra = 10px + 1px margin)
        final alturaBarra = 10.0;
        final margemBarra = 1.0;
        final alturaTextoExtra = 10.0; // para o +X
        
        final maxBarrasPossiveis = ((alturaDisponivel - alturaTextoExtra) / (alturaBarra + margemBarra)).floor();
        final maxBarras = maxBarrasPossiveis.clamp(1, 3);
        
        final eventosVisiveis = eventos.take(maxBarras).toList();
        final restantes = eventos.length - maxBarras;

        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: alturaNumeroDia, left: 2, right: 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...eventosVisiveis.asMap().entries.map((entry) {
                    final index = entry.key;
                    final evento = entry.value;
                    final cor = _cores[index % _cores.length];
                    return Container(
                      width: double.infinity,
                      height: alturaBarra,
                      margin: EdgeInsets.only(bottom: margemBarra),
                      decoration: BoxDecoration(
                        color: cor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Colors.white, Colors.transparent],
                            stops: [0.5, 1.0],
                          ).createShader(bounds),
                          blendMode: BlendMode.dstIn,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Text(
                              evento.clienteNome,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  if (restantes > 0)
                    Text(
                      '+$restantes',
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DiaCalendario extends StatelessWidget {
  const _DiaCalendario({
    required this.dia,
    this.corFundo,
    this.corTexto = Colors.black87,
    this.negrito = false,
  });

  final int dia;
  final Color? corFundo;
  final Color corTexto;
  final bool negrito;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade200,
          width: 0.5,
        ),
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Container(
            width: 26,
            height: 26,
            decoration: corFundo != null
                ? BoxDecoration(
                    color: corFundo,
                    shape: BoxShape.circle,
                  )
                : null,
            alignment: Alignment.center,
            child: Text(
              '$dia',
              style: TextStyle(
                color: corTexto,
                fontSize: 14,
                fontWeight: negrito ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DiaCalendarioCompacto extends StatelessWidget {
  const _DiaCalendarioCompacto({
    required this.dia,
    required this.selecionado,
    required this.hoje,
  });

  final DateTime dia;
  final bool selecionado;
  final bool hoje;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: selecionado
              ? const Color(0xFFCF7072)
              : hoje
                  ? const Color(0xFFFEC8C8)
                  : null,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '${dia.day}',
          style: TextStyle(
            color: selecionado
                ? Colors.white
                : hoje
                    ? const Color(0xFFCF7072)
                    : Colors.black87,
            fontWeight:
                selecionado || hoje ? FontWeight.bold : FontWeight.normal,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _GradeHorarios extends StatelessWidget {
  const _GradeHorarios({
    required this.scrollController,
    required this.agendamentos,
    required this.diaSelecionado,
    required this.onAgendamentoTap,
  });

  final ScrollController scrollController;
  final List<Agendamento> agendamentos;
  final DateTime diaSelecionado;
  final ValueChanged<Agendamento> onAgendamentoTap;

  static const double alturaHora = 60.0;
  static const int horaInicio = 0;
  static const int horaFim = 24;
  static const double paddingTopo = 20.0;

  @override
  Widget build(BuildContext context) {
    final agora = DateTime.now();
    final ehHoje = DateUtils.isSameDay(diaSelecionado, agora);
    final alturaTotal = (horaFim - horaInicio) * alturaHora + paddingTopo + 20;

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 88),
      child: SizedBox(
        height: alturaTotal,
        child: Stack(
          children: [
            Positioned(
              top: paddingTopo,
              left: 0,
              right: 0,
              bottom: 20,
              child: CustomPaint(
                size: Size(double.infinity, (horaFim - horaInicio) * alturaHora),
                painter: _GradeHorariosPainter(
                  horaInicio: horaInicio,
                  horaFim: horaFim,
                  alturaHora: alturaHora,
                ),
              ),
            ),
            ...agendamentos.map((agendamento) {
              return _BlocoAgendamento(
                agendamento: agendamento,
                horaInicio: horaInicio,
                alturaHora: alturaHora,
                paddingTopo: paddingTopo,
                onTap: () => onAgendamentoTap(agendamento),
              );
            }),
            if (ehHoje)
              _LinhaHoraAtual(
                horaInicio: horaInicio,
                alturaHora: alturaHora,
                paddingTopo: paddingTopo,
              ),
          ],
        ),
      ),
    );
  }
}

class _GradeHorariosPainter extends CustomPainter {
  _GradeHorariosPainter({
    required this.horaInicio,
    required this.horaFim,
    required this.alturaHora,
  });

  final int horaInicio;
  final int horaFim;
  final double alturaHora;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 0.5;

    final textPainter = TextPainter(
      textDirection: ui.TextDirection.ltr,
    );

    for (var hora = horaInicio; hora < horaFim; hora++) {
      final y = (hora - horaInicio) * alturaHora;

      canvas.drawLine(
        Offset(50, y),
        Offset(size.width, y),
        paint,
      );

      final horaFormatada = '${hora.toString().padLeft(2, '0')}:00';
      textPainter.text = TextSpan(
        text: horaFormatada,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 11,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(4, y - 6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BlocoAgendamento extends StatelessWidget {
  const _BlocoAgendamento({
    required this.agendamento,
    required this.horaInicio,
    required this.alturaHora,
    required this.onTap,
    this.paddingTopo = 0,
  });

  final Agendamento agendamento;
  final int horaInicio;
  final double alturaHora;
  final VoidCallback onTap;
  final double paddingTopo;

  static const _cores = <Color>[
    Color(0xFFCF7072),
    Color(0xFFF2AA4C),
    Color(0xFF9C89B8),
    Color(0xFF5A9E8F),
    Color(0xFF4D6CFA),
  ];

  @override
  Widget build(BuildContext context) {
    final inicio = agendamento.inicio;
    final fim = agendamento.fim ??
        inicio.add(Duration(minutes: agendamento.duracaoMinutos));

    final minutosDesdeInicio =
        (inicio.hour - horaInicio) * 60 + inicio.minute;
    final duracaoMinutos = fim.difference(inicio).inMinutes;

    final top = (minutosDesdeInicio / 60) * alturaHora + paddingTopo;
    final altura = (duracaoMinutos / 60) * alturaHora;

    final cor = _cores[agendamento.clienteNome.hashCode % _cores.length];
    final corClara = cor.withOpacity(0.15);

    final formatadorHora = DateFormat.Hm('pt_BR');

    return Positioned(
      top: top,
      left: 55,
      right: 8,
      height: altura.clamp(30.0, double.infinity),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: corClara,
            borderRadius: BorderRadius.circular(4),
            border: Border(
              left: BorderSide(color: cor, width: 3),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                agendamento.clienteNome,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: cor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (altura > 40)
                Text(
                  '${formatadorHora.format(inicio)} - ${formatadorHora.format(fim)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade700,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinhaHoraAtual extends StatelessWidget {
  const _LinhaHoraAtual({
    required this.horaInicio,
    required this.alturaHora,
    this.paddingTopo = 0,
  });

  final int horaInicio;
  final double alturaHora;
  final double paddingTopo;

  @override
  Widget build(BuildContext context) {
    final agora = DateTime.now();
    final minutosDesdeInicio = (agora.hour - horaInicio) * 60 + agora.minute;
    final top = (minutosDesdeInicio / 60) * alturaHora + paddingTopo;

    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFCF7072),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(
              height: 1.5,
              color: const Color(0xFFCF7072),
            ),
          ),
        ],
      ),
    );
  }
}
