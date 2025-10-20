import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'configuracao/firebase_configuracao.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _carregarVariaveisAmbiente();
  await FirebaseConfiguracao.inicializar();
  runApp(const SalonSchedulerApp());
}

Future<void> _carregarVariaveisAmbiente() async {
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    await dotenv.load(fileName: '.env.example');
  }
}
