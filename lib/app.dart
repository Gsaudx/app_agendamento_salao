import 'package:flutter/material.dart';

import 'dependencias/dependencias_widget.dart';
import 'screens/appointments_screen.dart';
import 'screens/clients_screen.dart';
import 'screens/editclient_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/newclient_screen.dart';
import 'screens/services_screen.dart';
import 'servicos/agendamentos_servico.dart';
import 'servicos/autenticacao_servico.dart';
import 'servicos/clientes_servico.dart';
import 'servicos/servicos_servico.dart';

class SalonSchedulerApp extends StatelessWidget {
  const SalonSchedulerApp({
    super.key,
    AutenticacaoServico? autenticacaoServico,
    ClientesServico? clientesServico,
    ServicosServico? servicosServico,
    AgendamentosServico? agendamentosServico,
  }) : _autenticacaoServico = autenticacaoServico,
       _clientesServico = clientesServico,
       _servicosServico = servicosServico,
       _agendamentosServico = agendamentosServico;

  final AutenticacaoServico? _autenticacaoServico;
  final ClientesServico? _clientesServico;
  final ServicosServico? _servicosServico;
  final AgendamentosServico? _agendamentosServico;

  @override
  Widget build(BuildContext context) {
    final autenticacao = _autenticacaoServico ?? AutenticacaoServico();
    final clientesServico = _clientesServico ?? ClientesServico();
    final servicosServico = _servicosServico ?? ServicosServico();
    final agendamentosServico = _agendamentosServico ?? AgendamentosServico();
    final rotaInicial = autenticacao.usuarioAtual != null
        ? HomeScreen.routeName
        : LoginScreen.routeName;

    return DependenciasWidget(
      autenticacao: autenticacao,
      clientes: clientesServico,
      servicos: servicosServico,
      agendamentos: agendamentosServico,
      child: MaterialApp(
        title: 'Salão Paula Barros',
        theme: _buildTheme(),
        initialRoute: rotaInicial,
        routes: {
          LoginScreen.routeName: (context) => const LoginScreen(),
          HomeScreen.routeName: (context) => const HomeScreen(),
          AppointmentsScreen.routeName: (context) => const AppointmentsScreen(),
          ClientsScreen.routeName: (context) => const ClientsScreen(),
          ServicesScreen.routeName: (context) => const ServicesScreen(),
          NewClientScreen.routeName: (context) => const NewClientScreen(),
          EditClientScreen.routeName: (context) => const EditClientScreen(),
        },
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          final overlay = Overlay.maybeOf(context);
          if (overlay == null) {
            return child ?? const SizedBox.shrink();
          }
          return SelectionArea(
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  ThemeData _buildTheme() {
    const seed = Color(0xFF9C27B0);
    final scheme = ColorScheme.fromSeed(seedColor: seed);
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      dividerColor: scheme.outlineVariant,
    );
  }
}
