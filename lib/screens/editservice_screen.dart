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

  static const _iconesDecorativos = <IconData>[
    Icons.content_cut,
    Icons.spa,
    Icons.face_retouching_natural,
    Icons.brush,
    Icons.auto_fix_high,
    Icons.dry_cleaning,
    Icons.palette,
    Icons.wash,
    Icons.star_outline,
    Icons.local_florist,
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
      body: Stack(
        children: [
          Positioned.fill(
            child: _buildIconesDecorativos(),
          ),
          Column(
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
        ],
      ),
    );
  }

  Widget _buildIconesDecorativos() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final largura = constraints.maxWidth;
        final altura = constraints.maxHeight;

        final posicoes = <_PosicaoIcone>[
          // Ícones na parte superior (atrás dos campos)
          _PosicaoIcone(0, largura * 0.02, altura * 0.02, 36),
          _PosicaoIcone(1, largura * 0.85, altura * 0.05, 32),
          _PosicaoIcone(2, largura * 0.40, altura * 0.08, 34),
          _PosicaoIcone(3, largura * 0.70, altura * 0.15, 38),
          _PosicaoIcone(4, largura * 0.10, altura * 0.18, 30),
          _PosicaoIcone(5, largura * 0.55, altura * 0.22, 36),
          _PosicaoIcone(6, largura * 0.88, altura * 0.28, 32),
          _PosicaoIcone(7, largura * 0.25, altura * 0.32, 34),
          // Ícones na parte do meio
          _PosicaoIcone(8, largura * 0.05, altura * 0.42, 38),
          _PosicaoIcone(9, largura * 0.78, altura * 0.45, 36),
          _PosicaoIcone(0, largura * 0.45, altura * 0.50, 32),
          // Ícones na parte inferior
          _PosicaoIcone(1, largura * 0.12, altura * 0.58, 40),
          _PosicaoIcone(2, largura * 0.85, altura * 0.62, 34),
          _PosicaoIcone(3, largura * 0.30, altura * 0.70, 38),
          _PosicaoIcone(4, largura * 0.68, altura * 0.75, 36),
          _PosicaoIcone(5, largura * 0.05, altura * 0.82, 32),
          _PosicaoIcone(6, largura * 0.50, altura * 0.88, 40),
          _PosicaoIcone(7, largura * 0.88, altura * 0.85, 34),
        ];

        return Stack(
          children: posicoes.map((pos) {
            return Positioned(
              left: pos.x,
              top: pos.y,
              child: Transform.rotate(
                angle: (pos.indice * 0.4) - 0.5,
                child: Icon(
                  _iconesDecorativos[pos.indice % _iconesDecorativos.length],
                  size: pos.tamanho,
                  color: const Color(0xFFCF7072).withOpacity(0.12),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _PosicaoIcone {
  final int indice;
  final double x;
  final double y;
  final double tamanho;

  _PosicaoIcone(this.indice, this.x, this.y, this.tamanho);
}
