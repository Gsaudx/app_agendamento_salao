import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/floating_button.dart';
import '../dependencias/dependencias_widget.dart';
import '../modelos/agendamento.dart';
import '../servicos/autenticacao_servico.dart';
import '../servicos/agendamentos_servico.dart';
import 'appointments_screen.dart';
import 'clients_screen.dart';
import 'login_screen.dart';
import 'services_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final autenticacao = DependenciasWidget.autenticacaoDe(context);
    final usuario = autenticacao.usuarioAtual;
    final nome = _nomeParaSaudacao(usuario);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda do Salão'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            onPressed: () => _sair(context, autenticacao),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          Text(
            'Bem-vindo(a), $nome!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pronto para organizar os atendimentos de hoje?',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          _DashboardCard(
            icon: Icons.calendar_month,
            title: 'Próximos agendamentos',
            description: 'Ver compromissos confirmados para hoje e amanhã.',
            onTap: () =>
                Navigator.pushNamed(context, AppointmentsScreen.routeName),
          ),
          _DashboardCard(
            icon: Icons.people_alt,
            title: 'Clientes',
            description: 'Listar contatos frequentes e preferências.',
            onTap: () => Navigator.pushNamed(context, ClientsScreen.routeName),
          ),
          _DashboardCard(
            icon: Icons.cut,
            title: 'Serviços',
            description: 'Consultar valores e tempo de cada atendimento.',
            onTap: () => Navigator.pushNamed(context, ServicesScreen.routeName),
          ),
          const SizedBox(height: 32),
          Text('Próximos agendamentos', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          _AgendaPreview(
            agendamentosServico: DependenciasWidget.agendamentosDe(context),
          ),
        ],
      ),
      floatingActionButton: FloatingButton(
        label: 'Novo agendamento',
        onPressed: () =>
            Navigator.pushNamed(context, AppointmentsScreen.routeName),
      ),
    );
  }

  Future<void> _sair(
    BuildContext context,
    AutenticacaoServico autenticacao,
  ) async {
    final navigator = Navigator.of(context);
    final mensageiro = ScaffoldMessenger.of(context);
    try {
      await autenticacao.sair();
      navigator.pushNamedAndRemoveUntil(LoginScreen.routeName, (_) => false);
    } catch (erro) {
      mensageiro.showSnackBar(
        SnackBar(content: Text('Não foi possível sair: $erro')),
      );
    }
  }
}

class _AgendaPreview extends StatelessWidget {
  const _AgendaPreview({required this.agendamentosServico});

  final AgendamentosServico agendamentosServico;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<List<Agendamento>>(
      stream: agendamentosServico.observarProximos(limite: 3),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Falha ao carregar agenda: ${snapshot.error}'),
          );
        }
        final agendamentos = snapshot.data ?? const <Agendamento>[];
        if (agendamentos.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Nenhum agendamento futuro. Que tal cadastrar um agora? ',
              style: theme.textTheme.bodyMedium,
            ),
          );
        }
        return Column(
          children: agendamentos
              .map(
                (agendamento) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                      child: Text(
                        '${agendamento.inicio.hour.toString().padLeft(2, '0')}h',
                      ),
                    ),
                    title: Text(agendamento.clienteNome),
                    subtitle: Text(agendamento.servicoNome),
                    trailing: const Icon(Icons.navigate_next),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppointmentsScreen.routeName,
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                child: Icon(icon, size: 26),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(description, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

String _nomeParaSaudacao(User? usuario) {
  final displayName = usuario?.displayName?.trim();
  if (displayName != null && displayName.isNotEmpty) {
    return _capitalizarCadaPalavra(displayName);
  }

  final email = usuario?.email;
  if (email != null && email.isNotEmpty) {
    final localPart = email.split('@').first.replaceAll(RegExp(r'[._]'), ' ');
    return _capitalizarCadaPalavra(localPart);
  }

  return 'por aqui';
}

String _capitalizarCadaPalavra(String texto) {
  final palavras = texto.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  return palavras
      .map(
        (palavra) => palavra.length == 1
            ? palavra.toUpperCase()
            : '${palavra[0].toUpperCase()}${palavra.substring(1).toLowerCase()}',
      )
      .join(' ');
}
