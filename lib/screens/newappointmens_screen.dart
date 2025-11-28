import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../components/app_bar_secundario.dart';
import '../components/Input.dart';
import '../components/button.dart';
import '../components/dialog_confirmacao.dart';
import '../components/input_date.dart';
import '../components/input_textarea.dart';
import '../components/select.dart';
import '../dependencias/dependencias_widget.dart';
import '../formatters/moeda_input_formatter.dart';
import '../modelos/agendamento.dart';
import '../modelos/cliente.dart';
import '../modelos/servico.dart';

class NewAppointmentScreenArguments {
  const NewAppointmentScreenArguments({
    this.dia,
    this.horaInicial,
    this.agendamento,
  });

  final DateTime? dia;
  final TimeOfDay? horaInicial;
  final Agendamento? agendamento;
}

class NewAppointmentScreen extends StatefulWidget {
  const NewAppointmentScreen({super.key});

  static const routeName = '/new-appointment';

  @override
  State<NewAppointmentScreen> createState() => _NewAppointmentScreenState();
}

class _NewAppointmentScreenState extends State<NewAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dataController = TextEditingController();
  final _valorController = TextEditingController();
  final _observacoesController = TextEditingController();
  final Set<String> _servicosSelecionados = <String>{};
  late final NumberFormat _moedaFormatador;

  Cliente? _clienteSelecionado;
  DateTime? _dataSelecionada;
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFim;
  bool _salvando = false;
  int _duracaoTotalMinutos = 0;
  Agendamento? _agendamentoOriginal;
  bool _clientePrefillAplicado = false;

  late final List<TimeOfDay> _horarios;
  bool _argumentosAplicados = false;

  Stream<List<Cliente>>? _clientesStream;
  Stream<List<Servico>>? _servicosStream;

  bool get _modoEdicao => _agendamentoOriginal != null;

  @override
  void initState() {
    super.initState();
    _moedaFormatador = NumberFormat.currency(locale: 'pt_BR', symbol: '');
    _horarios = _gerarHorarios();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_clientesStream == null) {
      final clientesServico = DependenciasWidget.clientesDe(context);
      _clientesStream = clientesServico.observarClientes();
    }
    if (_servicosStream == null) {
      final servicosServico = DependenciasWidget.servicosDe(context);
      _servicosStream = servicosServico.observarServicos();
    }

    if (_argumentosAplicados) {
      return;
    }
    final argumentos = ModalRoute.of(context)?.settings.arguments;
    if (argumentos is NewAppointmentScreenArguments) {
      if (argumentos.agendamento != null) {
        _agendamentoOriginal = argumentos.agendamento;
        final agendamento = argumentos.agendamento!;
        final dia = DateUtils.dateOnly(agendamento.inicio);
        _dataSelecionada = dia;
        _dataController.text = DateFormat('dd/MM/yyyy').format(dia);
        _horaInicio = TimeOfDay.fromDateTime(agendamento.inicio);
        final fimCalculado =
            agendamento.fim ??
            agendamento.inicio.add(
              Duration(minutes: agendamento.duracaoMinutos),
            );
        _horaFim = TimeOfDay.fromDateTime(fimCalculado);
        _duracaoTotalMinutos = agendamento.duracaoMinutos;
        _valorController.text = _moedaFormatador
            .format(agendamento.total)
            .trim();
        _observacoesController.text = agendamento.observacoes ?? '';
        _servicosSelecionados
          ..clear()
          ..addAll(agendamento.servicos.map((servico) => servico.id));
      } else {
        if (argumentos.dia != null) {
          final dia = DateUtils.dateOnly(argumentos.dia!);
          _dataSelecionada = dia;
          _dataController.text =
              '${dia.day.toString().padLeft(2, '0')}/${dia.month.toString().padLeft(2, '0')}/${dia.year}';
        }
        if (argumentos.horaInicial != null) {
          final horaAjustada = _alinharParaGrade(argumentos.horaInicial!);
          _horaInicio = horaAjustada;
          _horaFim = _calcularFim(
            horaAjustada,
            _duracaoTotalMinutos > 0 ? _duracaoTotalMinutos : 60,
          );
        }
      }
    }
    _argumentosAplicados = true;
  }

  @override
  void dispose() {
    _dataController.dispose();
    _valorController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarSecundario(
        titulo: _modoEdicao ? 'Editar Agendamento' : 'Novo Agendamento',
        icone: Icons.calendar_month_rounded,
      ),
      body: StreamBuilder<List<Cliente>>(
        stream: _clientesStream,
        builder: (context, clientesSnapshot) {
          if (clientesSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (clientesSnapshot.hasError) {
            return _ErroCarregamento(mensagem: '${clientesSnapshot.error}');
          }
          final clientes = clientesSnapshot.data ?? const <Cliente>[];
          if (clientes.isEmpty) {
            return const _AvisoVazio(
              mensagem: 'Cadastre um cliente antes de criar um agendamento.',
            );
          }

          if (_modoEdicao && !_clientePrefillAplicado) {
            try {
              final clienteEncontrado = clientes.firstWhere(
                (cliente) => cliente.id == _agendamentoOriginal?.clienteId,
              );
              _clienteSelecionado = clienteEncontrado;
            } catch (_) {
              _clienteSelecionado = null;
            }
            _clientePrefillAplicado = true;
          }

          return StreamBuilder<List<Servico>>(
            stream: _servicosStream,
            builder: (context, servicosSnapshot) {
              if (servicosSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (servicosSnapshot.hasError) {
                return _ErroCarregamento(mensagem: '${servicosSnapshot.error}');
              }
              final servicos = servicosSnapshot.data ?? const <Servico>[];
              if (servicos.isEmpty) {
                return const _AvisoVazio(
                  mensagem: 'Cadastre ao menos um serviço antes de agendar.',
                );
              }

              return Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    Select<Cliente>(
                      label: 'Adicionar Cliente',
                      placeholder: 'Selecione o cliente',
                      items: clientes,
                      value: _clienteSelecionado,
                      itemLabel: (cliente) => cliente.nome,
                      onChanged: (cliente) =>
                          setState(() => _clienteSelecionado = cliente),
                      validator: (cliente) =>
                          cliente == null ? 'Selecione um cliente' : null,
                    ),
                    const SizedBox(height: 8),
                    _ExpandableServiceSelect(
                      servicos: servicos,
                      selecionados: _servicosSelecionados,
                      onChange: () =>
                          setState(() => _aplicarSugestoes(servicos)),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: InputDate(
                            label: 'Dia',
                            controller: _dataController,
                            onDateSelected: (data) {
                              setState(() {
                                _dataSelecionada = DateTime(
                                  data.year,
                                  data.month,
                                  data.day,
                                );
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: Input(
                            label: 'Valor',
                            controller: _valorController,
                            placeholder: '0,00',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [MoedaInputFormatter()],
                            prefixText: 'R\$ ',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Select<TimeOfDay>(
                            label: 'Hora Início',
                            placeholder: '00:00',
                            items: _horarios,
                            value: _horaInicio,
                            itemLabel: (hora) => _formatarHora(hora),
                            onChanged: (hora) {
                              if (hora == null) {
                                return;
                              }
                              setState(() {
                                _horaInicio = hora;
                                if (_duracaoTotalMinutos > 0) {
                                  _horaFim = _calcularFim(
                                    hora,
                                    _duracaoTotalMinutos,
                                  );
                                } else if (_horaFim != null &&
                                    !_horaValida(_horaFim!, hora)) {
                                  _horaFim = null;
                                }
                              });
                            },
                            validator: (hora) => hora == null
                                ? 'Informe o horário inicial'
                                : null,
                          ),
                        ),
                        Expanded(
                          child: Select<TimeOfDay>(
                            label: 'Hora Fim',
                            placeholder: '00:00',
                            items: _horariosFim(),
                            value: _horaFim,
                            itemLabel: (hora) => _formatarHora(hora),
                            onChanged: (hora) => setState(() {
                              _horaFim = hora;
                            }),
                            validator: (hora) {
                              if (hora == null) {
                                return 'Informe o horário final';
                              }
                              if (_horaInicio != null &&
                                  !_horaValida(hora, _horaInicio!)) {
                                return 'Fim deve ser após o início';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    Textarea(
                      label: 'Observações',
                      controller: _observacoesController,
                      maxLines: 6,
                    ),
                    const SizedBox(height: 12),
                    Button(
                      color: const Color(0xFFCF7072),
                      label: _modoEdicao ? 'Salvar alterações' : 'Agendar',
                      loading: _salvando,
                      onPressed: _salvando
                          ? null
                          : () => _salvar(clientes, servicos),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _salvar(List<Cliente> clientes, List<Servico> servicos) async {
    final cliente = _clienteSelecionado;
    final data = _dataSelecionada;
    final horaInicio = _horaInicio;
    final horaFim = _horaFim;
    final selecionados = servicos
        .where((servico) => _servicosSelecionados.contains(servico.id))
        .toList();
    final valorDigitado =
        MoedaInputFormatter.toDouble(_valorController.text) ?? 0.0;

    if (!_formKey.currentState!.validate() ||
        cliente == null ||
        data == null ||
        horaInicio == null ||
        horaFim == null) {
      _mostrarMensagem('Preencha todos os campos obrigatórios.');
      return;
    }
    if (selecionados.isEmpty) {
      _mostrarMensagem('Selecione ao menos um serviço.');
      return;
    }
    if (!_horaValida(horaFim, horaInicio)) {
      _mostrarMensagem('Horário final deve ser após o inicial.');
      return;
    }

    final inicio = _combinarDataHora(data, horaInicio);
    final fim = _combinarDataHora(data, horaFim);
    final servicosResumo = selecionados
        .map(
          (servico) => AgendamentoServicoResumo(
            id: servico.id,
            nome: servico.nome,
            duracaoMinutos: servico.duracaoMinutos,
            preco: servico.preco,
          ),
        )
        .toList();
    // Usa o valor digitado pelo usuário (mesmo que seja R$0,00)
    // Se o campo de valor estiver vazio, usa o total sugerido pelos serviços
    final valorTexto = _valorController.text.trim();
    final usuarioEditouValor = valorTexto.isNotEmpty;
    final totalSugerido = selecionados.fold<double>(
      0.0,
      (total, servico) => total + servico.preco,
    );
    final total = usuarioEditouValor ? valorDigitado : totalSugerido;
    final observacoes = _observacoesController.text.trim();
    final observacoesOuNull = observacoes.isEmpty ? null : observacoes;

    FocusScope.of(context).unfocus();
    setState(() => _salvando = true);

    final agendamentosServico = DependenciasWidget.agendamentosDe(context);

    final conflito = await agendamentosServico.verificarConflito(
      inicio: inicio,
      fim: fim,
      ignorarId: _modoEdicao ? _agendamentoOriginal?.id : null,
    );

    if (conflito != null) {
      if (!mounted) return;
      setState(() => _salvando = false);

      final formatadorHora = DateFormat.Hm('pt_BR');
      final inicioConflito = formatadorHora.format(conflito.inicio);
      final fimConflito = formatadorHora.format(
        conflito.fim ??
            conflito.inicio.add(Duration(minutes: conflito.duracaoMinutos)),
      );

      await DialogConfirmacao.mostrar(
        context: context,
        titulo: 'Conflito de Horário',
        mensagem: 'Já existe um agendamento neste horário:\n\n'
            'Cliente: ${conflito.clienteNome}\n'
            'Horário: $inicioConflito - $fimConflito\n'
            'Serviços: ${conflito.descricaoServicos}',
        tipo: TipoDialogo.alerta,
        mostrarBotaoCancelar: false,
      );
      return;
    }

    try {
      if (_modoEdicao && _agendamentoOriginal != null) {
        await agendamentosServico.atualizarAgendamento(
          id: _agendamentoOriginal!.id,
          clienteId: cliente.id,
          clienteNome: cliente.nome,
          inicio: inicio,
          fim: fim,
          servicos: servicosResumo,
          total: total,
          observacoes: observacoesOuNull,
        );
      } else {
        await agendamentosServico.criarAgendamento(
          clienteId: cliente.id,
          clienteNome: cliente.nome,
          inicio: inicio,
          fim: fim,
          servicos: servicosResumo,
          total: total,
          observacoes: observacoesOuNull,
        );
      }
      if (!mounted) {
        return;
      }
      Navigator.pop(context, true);
    } catch (erro) {
      if (!mounted) {
        return;
      }
      _mostrarMensagem('Erro ao salvar agendamento: $erro');
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  void _aplicarSugestoes(List<Servico> servicos) {
    final selecionados = servicos
        .where((servico) => _servicosSelecionados.contains(servico.id))
        .toList();
    final duracao = selecionados.fold<int>(
      0,
      (total, servico) => total + servico.duracaoMinutos,
    );
    final total = selecionados.fold<double>(
      0.0,
      (valor, servico) => valor + servico.preco,
    );

    _duracaoTotalMinutos = duracao;
    if (total > 0) {
      final texto = _moedaFormatador.format(total).trim();
      _valorController.text = texto;
    } else {
      _valorController.clear();
    }

    if (_horaInicio != null && _duracaoTotalMinutos > 0) {
      _horaFim = _calcularFim(_horaInicio!, _duracaoTotalMinutos);
    } else if (_duracaoTotalMinutos == 0) {
      _horaFim = null;
    }
  }

  List<TimeOfDay> _horariosFim() {
    if (_horaInicio == null) {
      return _horarios;
    }
    final inicioMin = _minutosDesdeMeiaNoite(_horaInicio!);
    return _horarios
        .where((hora) => _minutosDesdeMeiaNoite(hora) > inicioMin)
        .toList();
  }

  List<TimeOfDay> _gerarHorarios() {
    final horarios = <TimeOfDay>[];
    for (int minuto = 6 * 60; minuto <= 23 * 60 + 45; minuto += 15) {
      final hora = minuto ~/ 60;
      final minutos = minuto % 60;
      horarios.add(TimeOfDay(hour: hora, minute: minutos));
    }
    horarios.add(const TimeOfDay(hour: 23, minute: 59));
    return horarios;
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

  TimeOfDay _calcularFim(TimeOfDay inicio, int duracaoMinutos) {
    final total = _minutosDesdeMeiaNoite(inicio) + duracaoMinutos;
    final hora = total ~/ 60;
    final minuto = total % 60;
    if (hora >= 24) {
      return const TimeOfDay(hour: 23, minute: 59);
    }
    return TimeOfDay(hour: hora, minute: minuto);
  }

  bool _horaValida(TimeOfDay fim, TimeOfDay inicio) {
    return _minutosDesdeMeiaNoite(fim) > _minutosDesdeMeiaNoite(inicio);
  }

  int _minutosDesdeMeiaNoite(TimeOfDay hora) => hora.hour * 60 + hora.minute;

  DateTime _combinarDataHora(DateTime data, TimeOfDay hora) {
    return DateTime(data.year, data.month, data.day, hora.hour, hora.minute);
  }

  String _formatarHora(TimeOfDay hora) {
    final horas = hora.hour.toString().padLeft(2, '0');
    final minutos = hora.minute.toString().padLeft(2, '0');
    return '$horas:$minutos';
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }
}

class _ExpandableServiceSelect extends StatefulWidget {
  const _ExpandableServiceSelect({
    required this.servicos,
    required this.selecionados,
    required this.onChange,
  });

  final List<Servico> servicos;
  final Set<String> selecionados;
  final VoidCallback onChange;

  @override
  State<_ExpandableServiceSelect> createState() =>
      _ExpandableServiceSelectState();
}

class _ExpandableServiceSelectState extends State<_ExpandableServiceSelect> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final selecionadosList = widget.servicos
        .where((s) => widget.selecionados.contains(s.id))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Serviços',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Row(
            children: [
              Expanded(
                child: selecionadosList.isEmpty
                    ? Text(
                        'Selecione os serviços',
                        style: tema.textTheme.bodyLarge?.copyWith(
                          color: tema.hintColor,
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: selecionadosList
                            .map(
                              (s) => Chip(
                                label: Text(s.nome),
                                onDeleted: () {
                                  widget.selecionados.remove(s.id);
                                  widget.onChange();
                                },
                              ),
                            )
                            .toList(),
                      ),
              ),
              IconButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                icon: Icon(_expanded ? Icons.remove : Icons.add),
                tooltip: _expanded ? 'Recolher' : 'Adicionar serviços',
              ),
            ],
          ),
          if (_expanded) ...[
            const Divider(),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.servicos.length,
                itemBuilder: (context, index) {
                  final servico = widget.servicos[index];
                  final isSelected = widget.selecionados.contains(servico.id);
                  return CheckboxListTile(
                    title: Text(servico.nome),
                    subtitle: Text(
                      NumberFormat.simpleCurrency(locale: 'pt_BR')
                          .format(servico.preco),
                    ),
                    value: isSelected,
                    onChanged: (checked) {
                      if (checked == true) {
                        widget.selecionados.add(servico.id);
                      } else {
                        widget.selecionados.remove(servico.id);
                      }
                      widget.onChange();
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    ),
    );
  }
}

class _ErroCarregamento extends StatelessWidget {
  const _ErroCarregamento({required this.mensagem});

  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text('Não foi possível carregar os dados.\n$mensagem'),
      ),
    );
  }
}

class _AvisoVazio extends StatelessWidget {
  const _AvisoVazio({required this.mensagem});

  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(mensagem, textAlign: TextAlign.center),
      ),
    );
  }
}
