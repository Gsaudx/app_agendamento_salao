import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../components/app_bar_secundario.dart';
import '../components/button.dart';
import '../components/Input.dart';
import '../components/input_textarea.dart';
import '../components/select.dart';
import '../dependencias/dependencias_widget.dart';
import '../formatters/moeda_input_formatter.dart';
import '../modelos/servico.dart';

class EditServiceScreen extends StatefulWidget {
  const EditServiceScreen({super.key});

  static const routeName = '/edit-service';

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  late final TextEditingController _nomeController;
  late final TextEditingController _precoController;
  late final TextEditingController _descricaoController;
  Servico? _servico;
  int? _duracaoSelecionada;
  bool _salvando = false;

  static const _duracoesDisponiveis = <int>[
    15, 20, 30, 45, 60, 75, 90, 105, 120, 150, 180, 210, 240, 270
  ];

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _precoController = TextEditingController();
    _descricaoController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final argumentos = ModalRoute.of(context)?.settings.arguments;
    if (_servico == null && argumentos is Servico) {
      _servico = argumentos;
      _nomeController.text = argumentos.nome;
      _precoController.text = NumberFormat.currency(
        locale: 'pt_BR',
        symbol: '',
      ).format(argumentos.preco).trim();
      _descricaoController.text = argumentos.descricao ?? '';
      _duracaoSelecionada = argumentos.duracaoMinutos;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _precoController.dispose();
    _descricaoController.dispose();
    super.dispose();
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

  Future<void> _salvarServico() async {
    final nome = _nomeController.text.trim();
    final preco = MoedaInputFormatter.toDouble(_precoController.text) ?? -1;

    if (nome.isEmpty || _duracaoSelecionada == null || preco < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe nome, duração e um preço válido.'),
        ),
      );
      return;
    }

    setState(() => _salvando = true);

    try {
      final servicosServico = DependenciasWidget.servicosDe(context);
      await servicosServico.atualizarServico(
        _servico!.id,
        nome: nome,
        duracaoMinutos: _duracaoSelecionada!,
        preco: preco,
        descricao: _descricaoController.text.trim().isEmpty
            ? null
            : _descricaoController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (erro) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível salvar: $erro')),
        );
        setState(() => _salvando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_servico == null) {
      return Scaffold(
        appBar: const AppBarSecundario(
          titulo: 'Editar Serviço',
          icone: Icons.content_cut_rounded,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Nenhum serviço selecionado.'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const AppBarSecundario(
        titulo: 'Editar Serviço',
        icone: Icons.content_cut_rounded,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Input(
                  label: 'Nome',
                  controller: _nomeController,
                  placeholder: 'Digite o nome do serviço',
                ),
                Select<int>(
                  label: 'Duração',
                  placeholder: 'Selecione a duração',
                  items: _duracoesDisponiveis,
                  value: _duracaoSelecionada,
                  onChanged: (valor) =>
                      setState(() => _duracaoSelecionada = valor),
                  itemLabel: (valor) => _formatarDuracao(valor),
                ),
                Input(
                  label: 'Preço',
                  controller: _precoController,
                  placeholder: '0,00',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [MoedaInputFormatter()],
                  prefixText: 'R\$ ',
                ),
                Textarea(
                  label: 'Descrição (opcional)',
                  controller: _descricaoController,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                Button(
                  label: 'Salvar',
                  onPressed: _salvando ? null : _salvarServico,
                  loading: _salvando,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
