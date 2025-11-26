import 'package:flutter/material.dart';

import '../components/button.dart';
import '../components/foto_cliente_selector.dart';
import '../components/Input.dart';
import '../components/input_date.dart';
import '../components/input_textarea.dart';
import '../dependencias/dependencias_widget.dart';
import '../formatters/telefone_input_formatter.dart';
import '../modelos/cliente.dart';

class EditClientScreen extends StatefulWidget {
  const EditClientScreen({super.key});

  static const routeName = '/edit-client';

  @override
  State<EditClientScreen> createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
  late final TextEditingController _nomeController;
  late final TextEditingController _telefoneController;
  late final TextEditingController _nascimentoController;
  late final TextEditingController _emailController;
  late final TextEditingController _anotacoesController;
  Cliente? _cliente;
  FotoSelecionada? _fotoSelecionada;
  String? _fotoUrlAtual;
  bool _removerFotoAtual = false;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _telefoneController = TextEditingController();
    _nascimentoController = TextEditingController();
    _emailController = TextEditingController();
    _anotacoesController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final argumentos = ModalRoute.of(context)?.settings.arguments;
    if (_cliente == null && argumentos is Cliente) {
      _cliente = argumentos;
      _nomeController.text = argumentos.nome;
      _telefoneController.text = TelefoneInputFormatter.formatValue(
        argumentos.telefone,
      );
      _emailController.text = argumentos.email ?? '';
      _anotacoesController.text = argumentos.observacoes ?? '';
      _fotoUrlAtual = argumentos.fotoUrl;
      if (argumentos.dataNascimento != null) {
        final data = argumentos.dataNascimento!;
        _nascimentoController.text =
            '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
      }
    }
  }

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
    if (_cliente == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar Cliente')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Nenhum cliente selecionado.'),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Cliente')),
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
                    FotoClienteSelector(
                      fotoUrl: _removerFotoAtual ? null : _fotoUrlAtual,
                      fotoSelecionada: _fotoSelecionada,
                      carregando: _salvando,
                      onFotoSelecionada: (foto) {
                        setState(() {
                          _fotoSelecionada = foto;
                          _removerFotoAtual = false;
                        });
                      },
                      onRemoverFoto: () {
                        setState(() {
                          _fotoSelecionada = null;
                          _removerFotoAtual = true;
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
    final cliente = _cliente;
    if (cliente == null) {
      return;
    }
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
      String? novaFotoUrl = _fotoUrlAtual;

      // Se tiver nova foto selecionada, faz upload
      if (_fotoSelecionada != null) {
        novaFotoUrl = await storageServico.uploadFotoCliente(
          clienteId: cliente.id,
          bytes: _fotoSelecionada!.bytes,
          extensao: _fotoSelecionada!.extensao,
        );
      } else if (_removerFotoAtual) {
        // Se pediu para remover, deleta a foto antiga
        await storageServico.deletarFotoCliente(cliente.id);
        novaFotoUrl = null;
      }

      await clientesServico.atualizarCliente(
        cliente.id,
        nome: nome,
        telefone: telefone,
        email: _emailController.text.trim(),
        dataNascimento: _parseNascimento(),
        observacoes: _anotacoesController.text.trim(),
        fotoUrl: novaFotoUrl,
      );

      // Atualiza a foto separadamente se necessário
      if (_removerFotoAtual || _fotoSelecionada != null) {
        await clientesServico.atualizarFotoCliente(cliente.id, novaFotoUrl);
      }

      if (!mounted) {
        return;
      }
      Navigator.pop(context, true);
    } catch (erro) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar cliente: $erro')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }
}
