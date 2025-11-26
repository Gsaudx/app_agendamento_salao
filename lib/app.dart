import 'package:app_paula_barros/screens/history_screen.dart';
import 'package:app_paula_barros/screens/newappointmens_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
import 'servicos/storage_servico.dart';

class SalonSchedulerApp extends StatelessWidget {
  const SalonSchedulerApp({
    super.key,
    AutenticacaoServico? autenticacaoServico,
    ClientesServico? clientesServico,
    ServicosServico? servicosServico,
    AgendamentosServico? agendamentosServico,
    StorageServico? storageServico,
  }) : _autenticacaoServico = autenticacaoServico,
       _clientesServico = clientesServico,
       _servicosServico = servicosServico,
       _agendamentosServico = agendamentosServico,
       _storageServico = storageServico;

  final AutenticacaoServico? _autenticacaoServico;
  final ClientesServico? _clientesServico;
  final ServicosServico? _servicosServico;
  final AgendamentosServico? _agendamentosServico;
  final StorageServico? _storageServico;

  @override
  Widget build(BuildContext context) {
    final autenticacao = _autenticacaoServico ?? AutenticacaoServico();
    final clientesServico = _clientesServico ?? ClientesServico();
    final servicosServico = _servicosServico ?? ServicosServico();
    final agendamentosServico = _agendamentosServico ?? AgendamentosServico();
    final storageServico = _storageServico ?? StorageServico();
    final rotaInicial = autenticacao.usuarioAtual != null
        ? HomeScreen.routeName
        : LoginScreen.routeName;

    return DependenciasWidget(
      autenticacao: autenticacao,
      clientes: clientesServico,
      servicos: servicosServico,
      agendamentos: agendamentosServico,
      storage: storageServico,
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
          NewAppointmentScreen.routeName: (context) => const NewAppointmentScreen(),
          HistoryScreen.routeName: (context) => const HistoryScreen(),
        },
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          final overlay = Overlay.maybeOf(context);
          if (overlay == null) {
            return child ?? const SizedBox.shrink();
          }
          return SelectionArea(child: child ?? const SizedBox.shrink());
        },
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
