import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseConfiguracao {
  const FirebaseConfiguracao._();

  static FirebaseOptions carregarOpcoes() {
    return FirebaseOptions(
      apiKey: _obterVariavel('FIREBASE_API_KEY'),
      appId: _obterVariavel('FIREBASE_APP_ID'),
      projectId: _obterVariavel('FIREBASE_PROJECT_ID'),
      messagingSenderId: _obterVariavel('FIREBASE_MESSAGING_SENDER_ID'),
      storageBucket: _obterVariavel('FIREBASE_STORAGE_BUCKET'),
      authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN'],
    );
  }

  static Future<void> inicializar() async {
    if (Firebase.apps.isNotEmpty) {
      return;
    }
    await Firebase.initializeApp(options: carregarOpcoes());
  }

  static String _obterVariavel(String chave) {
    final valor = dotenv.env[chave];
    if (valor == null || valor.isEmpty) {
      throw StateError('Variável de ambiente "$chave" não configurada.');
    }
    return valor;
  }
}
