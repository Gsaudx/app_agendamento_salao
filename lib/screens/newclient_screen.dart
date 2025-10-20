import 'package:flutter/material.dart';

import '../components/button.dart';
import '../components/input.dart';
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
  bool _salvando = false;

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
      appBar: AppBar(title: const Text('Novo Cliente')),
      body: Column(
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
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // TODO: abrir seletor de imagem
                          },
                          child: CircleAvatar(
                            radius: 120, // maior tamanho
                            backgroundColor: Colors.grey[300],
                            child: const Icon(
                              Icons.person,
                              size: 200, // ajusta o ícone ao novo raio
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            // TODO: abrir seletor de imagem
                          },
                          child: const Text('Adicionar foto'),
                        ),
                      ],
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
    try {
      await clientesServico.criarCliente(
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
