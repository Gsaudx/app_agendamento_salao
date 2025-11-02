import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Preservando as importações do usuário (assumindo que dependencias_widget.dart e home_screen.dart existem)
import 'package:app_paula_barros/dependencias/dependencias_widget.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _modoCadastro = false;
  bool _exibindoSenha = false;
  bool _carregandoEmailSenha = false;
  bool _carregandoGoogle = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  // Corrigido: As chaves e parênteses que estavam fora de ordem na lista children
  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFEC8C8),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Logo
              Padding(
                padding: const EdgeInsets.only(top: 48.0, bottom: 24.0),
                child: Image.asset(
                  'assets/img/logo_paula_barros.png',
                  height: 240,
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    color: const Color.fromARGB(255, 252, 218, 218),
                    elevation: 50,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _modoCadastro
                                  ? 'Registre-se'
                                  : 'Login',
                              style: tema.textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 24),
                            // Campo Nome
                            if (_modoCadastro) ...[
                              TextFormField(
                                controller: _nomeController,
                                textCapitalization: TextCapitalization.words,
                                decoration: const InputDecoration(
                                  labelText: 'Nome completo',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (valor) {
                                  if (!_modoCadastro) {
                                    return null;
                                  }
                                  if (valor == null || valor.trim().isEmpty) {
                                    return 'Informe seu nome';
                                  }
                                  if (valor.trim().length < 2) {
                                    return 'Nome muito curto';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                            // Campo E-mail
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
                            // Campo Senha
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
                            // Botão Entrar/Cadastrar (E-mail/Senha)
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
                                          // Adicionei uma cor para ser visível
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        _modoCadastro ? 'Cadastrar' : 'Entrar',
                                      ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Botão Entrar com Google
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
                            // Botão Alternar Modo
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
            ],
          ),
        ),
      ),
    );
  }

  void _alternarModo() {
    setState(() {
      _modoCadastro = !_modoCadastro;
      if (!_modoCadastro) {
        _nomeController.clear();
      }
      // Garante que o estado de validação do formulário seja redefinido
      _formKey.currentState?.reset();
    });
  }

  // --- LÓGICA DE AUTENTICAÇÃO ---

  Future<void> _autenticarEmailSenha() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _carregandoEmailSenha = true;
    });
    // Uso de DependenciasWidget (mantido conforme código original)
    final autenticacao = DependenciasWidget.autenticacaoDe(context);
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();
    final nome = _modoCadastro ? _nomeController.text.trim() : null;
    try {
      if (_modoCadastro) {
        final credencial = await autenticacao.cadastrarEmailSenha(
          email: email,
          senha: senha,
        );
        final usuario = credencial.user;
        if (usuario != null && (nome?.isNotEmpty ?? false)) {
          await usuario.updateDisplayName(nome);
        }
      } else {
        await autenticacao.entrarEmailSenha(email: email, senha: senha);
      }
      if (!mounted) {
        return;
      }
      // Navega para a HomeScreen
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
    // Uso de DependenciasWidget (mantido conforme código original)
    final autenticacao = DependenciasWidget.autenticacaoDe(context);
    try {
      await autenticacao.entrarGoogle();
      if (!mounted) {
        return;
      }
      // Navega para a HomeScreen
      Navigator.pushNamedAndRemoveUntil(
        context,
        HomeScreen.routeName,
        (_) => false,
      );
    } on FirebaseAuthException catch (erro) {
      _exibirMensagemErro(erro.message ?? 'Falha ao entrar com Google.');
    } on StateError catch (erro) {
      // Verifica se o erro é o cancelamento do login pelo usuário
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
