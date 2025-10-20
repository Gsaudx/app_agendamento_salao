import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:app_paula_barros/dependencias/dependencias_widget.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _modoCadastro = false;
  bool _exibindoSenha = false;
  bool _carregandoEmailSenha = false;
  bool _carregandoGoogle = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _modoCadastro ? 'Crie sua conta' : 'Acesse sua conta',
                        style: tema.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          border: OutlineInputBorder(),
                        ),
                        validator: (valor) {
                          if (valor == null || valor.trim().isEmpty) {
                            return 'Informe o e-mail';
                          }
                          if (!valor.contains('@')) {
                            return 'E-mail inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _senhaController,
                        obscureText: !_exibindoSenha,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _exibindoSenha = !_exibindoSenha;
                              });
                            },
                            icon: Icon(
                              _exibindoSenha
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                        validator: (valor) {
                          if (valor == null || valor.trim().isEmpty) {
                            return 'Informe a senha';
                          }
                          if (valor.length < 6) {
                            return 'A senha deve ter ao menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _carregandoEmailSenha
                              ? null
                              : _autenticarEmailSenha,
                          child: _carregandoEmailSenha
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(_modoCadastro ? 'Cadastrar' : 'Entrar'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _carregandoGoogle
                              ? null
                              : _autenticarGoogle,
                          icon: _carregandoGoogle
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.login),
                          label: const Text('Entrar com Google'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _alternarModo,
                        child: Text(
                          _modoCadastro
                              ? 'Já tenho conta, voltar para login'
                              : 'Criar uma conta',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _alternarModo() {
    setState(() {
      _modoCadastro = !_modoCadastro;
    });
  }

  Future<void> _autenticarEmailSenha() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _carregandoEmailSenha = true;
    });
    final autenticacao = DependenciasWidget.autenticacaoDe(context);
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();
    try {
      if (_modoCadastro) {
        await autenticacao.cadastrarEmailSenha(email: email, senha: senha);
      } else {
        await autenticacao.entrarEmailSenha(email: email, senha: senha);
      }
      if (!mounted) {
        return;
      }
      Navigator.pushNamedAndRemoveUntil(
        context,
        HomeScreen.routeName,
        (_) => false,
      );
    } on FirebaseAuthException catch (erro) {
      _exibirMensagemErro(erro.message ?? 'Falha na autenticação.');
    } catch (erro) {
      _exibirMensagemErro(erro.toString());
    } finally {
      if (mounted) {
        setState(() {
          _carregandoEmailSenha = false;
        });
      }
    }
  }

  Future<void> _autenticarGoogle() async {
    setState(() {
      _carregandoGoogle = true;
    });
    final autenticacao = DependenciasWidget.autenticacaoDe(context);
    try {
      await autenticacao.entrarGoogle();
      if (!mounted) {
        return;
      }
      Navigator.pushNamedAndRemoveUntil(
        context,
        HomeScreen.routeName,
        (_) => false,
      );
    } on FirebaseAuthException catch (erro) {
      _exibirMensagemErro(erro.message ?? 'Falha ao entrar com Google.');
    } on StateError catch (erro) {
      if (erro.message.contains('cancelada')) {
        _exibirMensagemErro('Login cancelado.');
      }
    } catch (erro) {
      _exibirMensagemErro(erro.toString());
    } finally {
      if (mounted) {
        setState(() {
          _carregandoGoogle = false;
        });
      }
    }
  }

  void _exibirMensagemErro(String mensagem) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }
}
