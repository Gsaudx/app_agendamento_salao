import 'package:app_paula_barros/screens/history_screen.dart';
import 'package:app_paula_barros/screens/newappointmens_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dependencias/dependencias_widget.dart';
import 'screens/appointments_screen.dart';
import 'screens/clients_screen.dart';
import 'screens/editclient_screen.dart';
import 'screens/editservice_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/newclient_screen.dart';
import 'screens/newservice_screen.dart';
import 'screens/services_screen.dart';
import 'servicos/agendamentos_servico.dart';
import 'servicos/autenticacao_servico.dart';
import 'servicos/clientes_servico.dart';
import 'servicos/servicos_servico.dart';
import 'servicos/storage_servico.dart';

class SalonSchedulerApp extends StatefulWidget {
  const SalonSchedulerApp({
    super.key,
    AutenticacaoServico? autenticacaoServico,
  }) : _autenticacaoServico = autenticacaoServico;

  final AutenticacaoServico? _autenticacaoServico;

  @override
  State<SalonSchedulerApp> createState() => _SalonSchedulerAppState();
}

class _SalonSchedulerAppState extends State<SalonSchedulerApp> {
  late final AutenticacaoServico _autenticacao;

  @override
  void initState() {
    super.initState();
    _autenticacao = widget._autenticacaoServico ?? AutenticacaoServico();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _autenticacao.fluxoUsuario,
      builder: (context, snapshot) {
        final usuario = snapshot.data;
        final userId = usuario?.uid;

        // Se não há usuário logado, mostra apenas a tela de login
        if (userId == null) {
          return _buildApp(
            autenticacao: _autenticacao,
            clientes: null,
            servicos: null,
            agendamentos: null,
            storage: null,
            rotaInicial: LoginScreen.routeName,
            userId: null,
          );
        }

        // Usuário logado - cria serviços com o userId
        final clientesServico = ClientesServico(userId: userId);
        final servicosServico = ServicosServico(userId: userId);
        final agendamentosServico = AgendamentosServico(userId: userId);
        final storageServico = StorageServico(userId: userId);

        return _buildApp(
          autenticacao: _autenticacao,
          clientes: clientesServico,
          servicos: servicosServico,
          agendamentos: agendamentosServico,
          storage: storageServico,
          rotaInicial: HomeScreen.routeName,
          userId: userId,
        );
      },
    );
  }

  Widget _buildApp({
    required AutenticacaoServico autenticacao,
    required ClientesServico? clientes,
    required ServicosServico? servicos,
    required AgendamentosServico? agendamentos,
    required StorageServico? storage,
    required String rotaInicial,
    String? userId,
  }) {
    return DependenciasWidget(
      key: ValueKey('deps_$userId'),
      autenticacao: autenticacao,
      clientes: clientes,
      servicos: servicos,
      agendamentos: agendamentos,
      storage: storage,
      child: MaterialApp(
        key: ValueKey('app_$userId'),
        title: 'Salão Paula Barros',
        theme: _buildTheme(),
        home: userId == null ? const LoginScreen() : const HomeScreen(),
        onGenerateRoute: (settings) {
          final routes = <String, WidgetBuilder>{
            LoginScreen.routeName: (context) => const LoginScreen(),
            AppointmentsScreen.routeName: (context) => const AppointmentsScreen(),
            ClientsScreen.routeName: (context) => const ClientsScreen(),
            ServicesScreen.routeName: (context) => const ServicesScreen(),
            NewClientScreen.routeName: (context) => const NewClientScreen(),
            EditClientScreen.routeName: (context) => const EditClientScreen(),
            NewServiceScreen.routeName: (context) => const NewServiceScreen(),
            EditServiceScreen.routeName: (context) => const EditServiceScreen(),
            NewAppointmentScreen.routeName: (context) => const NewAppointmentScreen(),
            HistoryScreen.routeName: (context) => const HistoryScreen(),
          };
          final builder = routes[settings.name];
          if (builder != null) {
            return MaterialPageRoute(
              builder: builder,
              settings: settings,
            );
          }
          return null;
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  ThemeData _buildTheme() {
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFFFEC8C8));
    final textTheme = GoogleFonts.openSansTextTheme();
    const buttonColor = Color(0xFFCF7072);
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      textTheme: textTheme,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        titleTextStyle: GoogleFonts.openSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: buttonColor,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: buttonColor,
          side: const BorderSide(color: buttonColor),
        ),
      ),
      dividerColor: scheme.outlineVariant,
    );
  }
}
