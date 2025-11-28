import 'package:flutter/material.dart';

import '../components/app_bar_secundario.dart';
import '../components/button.dart';
import '../components/foto_cliente_selector.dart';
import '../components/Input.dart';
import '../components/input_date.dart';
import '../components/input_textarea.dart';
import '../dependencias/dependencias_widget.dart';
import '../formatters/telefone_input_formatter.dart';

class NewClientScreen extends StatefulWidget {
  const NewClientScreen({super.key});

  static const routeName = '/new-client';

  @override
  State<NewClientScreen> createState() => _NewClientScreenState();
}

class _NewClientScreenState extends State<NewClientScreen> {
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _nascimentoController = TextEditingController();
  final _emailController = TextEditingController();
  final _anotacoesController = TextEditingController();
  FotoSelecionada? _fotoSelecionada;
  bool _salvando = false;

  static const _iconesDecorativos = <IconData>[
    Icons.person_outline,
    Icons.favorite_outline,
    Icons.star_outline,
    Icons.local_florist,
    Icons.spa,
    Icons.face_retouching_natural,
    Icons.cake_outlined,
    Icons.phone_outlined,
    Icons.email_outlined,
    Icons.edit_note,
  ];

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _nascimentoController.dispose();
    _emailController.dispose();
    _anotacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarSecundario(
        titulo: 'Novo Cliente',
        icone: Icons.person_add_rounded,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: _buildIconesDecorativos(),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FotoClienteSelector(
                          fotoSelecionada: _fotoSelecionada,
                          carregando: _salvando,
                          onFotoSelecionada: (foto) {
                            setState(() {
                              _fotoSelecionada = foto;
                            });
                          },
                          onRemoverFoto: () {
                            setState(() {
                              _fotoSelecionada = null;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Input(
                      label: 'Nome',
                      controller: _nomeController,
                      placeholder: 'Digite o nome da cliente',
                    ),
                    Input(
                      label: 'Telefone',
                      controller: _telefoneController,
                      keyboardType: TextInputType.phone,
                      placeholder: '(11) 99999-9999',
                      inputFormatters: const [TelefoneInputFormatter()],
                    ),
                    InputDate(
                      label: 'Data de Nascimento',
                      controller: _nascimentoController,
                      keyboardType: TextInputType.phone,
                    ),
                    Input(
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      placeholder: 'email@exemplo.com',
                    ),
                    Textarea(
                      label: 'Anotações',
                      controller: _anotacoesController,
                      maxLines: 6,
                    ),
                    const SizedBox(height: 20),
                    Button(
                      label: 'Salvar Cliente',
                      onPressed: _salvando ? null : _salvar,
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

  DateTime? _parseNascimento() {
    final texto = _nascimentoController.text.trim();
    if (texto.isEmpty) {
      return null;
    }
    final partes = texto.split('/');
    if (partes.length != 3) {
      return null;
    }
    try {
      final dia = int.parse(partes[0]);
      final mes = int.parse(partes[1]);
      final ano = int.parse(partes[2]);
      return DateTime(ano, mes, dia);
    } catch (_) {
      return null;
    }
  }

  Future<void> _salvar() async {
    final nome = _nomeController.text.trim();
    final telefone = TelefoneInputFormatter.digitsOnly(
      _telefoneController.text,
    );
    if (nome.isEmpty || telefone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe ao menos nome e telefone.')),
      );
      return;
    }
    setState(() {
      _salvando = true;
    });

    final clientesServico = DependenciasWidget.clientesDe(context);
    final storageServico = DependenciasWidget.storageDe(context);

    try {
      // Primeiro cria o cliente para obter o ID
      final clienteId = await clientesServico.criarCliente(
        nome: nome,
        telefone: telefone,
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        dataNascimento: _parseNascimento(),
        observacoes: _anotacoesController.text.trim().isEmpty
            ? null
            : _anotacoesController.text.trim(),
      );

      // Se tiver foto selecionada, faz o upload
      if (_fotoSelecionada != null) {
        final fotoUrl = await storageServico.uploadFotoCliente(
          clienteId: clienteId,
          bytes: _fotoSelecionada!.bytes,
          extensao: _fotoSelecionada!.extensao,
        );
        // Atualiza o cliente com a URL da foto
        await clientesServico.atualizarFotoCliente(clienteId, fotoUrl);
      }

      if (!mounted) {
        return;
      }
      Navigator.pop(context, true);
    } catch (erro) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar cliente: $erro')));
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }
}

class _PosicaoIcone {
  final int indice;
  final double x;
  final double y;
  final double tamanho;

  _PosicaoIcone(this.indice, this.x, this.y, this.tamanho);
}
