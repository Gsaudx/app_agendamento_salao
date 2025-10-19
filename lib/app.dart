import 'package:flutter/material.dart';

import 'screens/appointments_screen.dart';
import 'screens/clients_screen.dart';
import 'screens/home_screen.dart';
import 'screens/services_screen.dart';
import 'screens/newclient_screen.dart';

class SalonSchedulerApp extends StatelessWidget {
  const SalonSchedulerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salão Paula Barros',
      theme: _buildTheme(),
      initialRoute: HomeScreen.routeName,
      routes: {
        HomeScreen.routeName: (context) => const HomeScreen(),
        AppointmentsScreen.routeName: (context) => const AppointmentsScreen(),
        ClientsScreen.routeName: (context) => const ClientsScreen(),
        ServicesScreen.routeName: (context) => const ServicesScreen(),
        NewClientScreen.routeName: (context) => const NewClientScreen(),
      },
      debugShowCheckedModeBanner: false,
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
