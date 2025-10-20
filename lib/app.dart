import 'package:flutter/material.dart';

import 'dependencias/dependencias_widget.dart';
import 'screens/appointments_screen.dart';
import 'screens/clients_screen.dart';
import 'screens/editclient_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/newclient_screen.dart';
import 'screens/services_screen.dart';
import 'servicos/autenticacao_servico.dart';

class SalonSchedulerApp extends StatelessWidget {
  const SalonSchedulerApp({super.key, AutenticacaoServico? autenticacaoServico})
      : _autenticacaoServico = autenticacaoServico;

  final AutenticacaoServico? _autenticacaoServico;

  @override
  Widget build(BuildContext context) {
    final autenticacao = _autenticacaoServico ?? AutenticacaoServico();
    final rotaInicial = autenticacao.usuarioAtual != null ? HomeScreen.routeName : LoginScreen.routeName;

    return DependenciasWidget(
      autenticacao: autenticacao,
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
