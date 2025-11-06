import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../components/Input.dart';
import '../components/button.dart';
import '../components/input_date.dart';
import '../components/input_textarea.dart';
import '../components/select.dart';
import '../dependencias/dependencias_widget.dart';
import '../formatters/moeda_input_formatter.dart';
import '../modelos/agendamento.dart';
import '../modelos/cliente.dart';
import '../modelos/servico.dart';

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

  late final List<TimeOfDay> _horarios;

  @override
  void initState() {
    super.initState();
    _moedaFormatador = NumberFormat.currency(locale: 'pt_BR', symbol: '');
    _horarios = _gerarHorarios();
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
    final clientesServico = DependenciasWidget.clientesDe(context);
    final servicosServico = DependenciasWidget.servicosDe(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 252, 218, 218),
        title: const Text('Novo Agendamento'),
      ),
      body: StreamBuilder<List<Cliente>>(
        stream: clientesServico.observarClientes(),
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

          return StreamBuilder<List<Servico>>(
            stream: servicosServico.observarServicos(),
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
                    _MultiSelectServicos(
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
                      label: 'Agendar',
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
    final totalSugerido = selecionados.fold<double>(
      0.0,
      (total, servico) => total + servico.preco,
    );
    final total = valorDigitado > 0 ? valorDigitado : totalSugerido;

    FocusScope.of(context).unfocus();
    setState(() => _salvando = true);

    final agendamentosServico = DependenciasWidget.agendamentosDe(context);
    try {
      await agendamentosServico.criarAgendamento(
        clienteId: cliente.id,
        clienteNome: cliente.nome,
        inicio: inicio,
        fim: fim,
        servicos: servicosResumo,
        total: total,
        observacoes: _observacoesController.text.trim().isEmpty
            ? null
            : _observacoesController.text.trim(),
      );
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
    for (int minuto = 6 * 60; minuto <= 22 * 60 + 45; minuto += 15) {
      final hora = minuto ~/ 60;
      final minutos = minuto % 60;
      horarios.add(TimeOfDay(hour: hora, minute: minutos));
    }
    horarios.add(const TimeOfDay(hour: 23, minute: 59));
    return horarios;
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

class _MultiSelectServicos extends StatelessWidget {
  const _MultiSelectServicos({
    required this.servicos,
    required this.selecionados,
    required this.onChange,
  });

  final List<Servico> servicos;
  final Set<String> selecionados;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Serviços',
        hintText: 'Selecione um ou mais serviços',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: servicos
            .map(
              (servico) => FilterChip(
                label: Text(servico.nome),
                selected: selecionados.contains(servico.id),
                onSelected: (_) {
                  if (selecionados.contains(servico.id)) {
                    selecionados.remove(servico.id);
                  } else {
                    selecionados.add(servico.id);
                  }
                  onChange();
                },
                selectedColor: tema.colorScheme.primaryContainer,
                checkmarkColor: tema.colorScheme.onPrimaryContainer,
              ),
            )
            .toList(),
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
