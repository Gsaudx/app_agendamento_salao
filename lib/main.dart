import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDh7JggGm0RoozXofNeNjKdMummPRTYs0k',
      appId: '1:445326453635:web:07297bfa6ed1a0368724b6',
      messagingSenderId: '445326453635',
      projectId: 'app-agendamento-salao',
      authDomain: 'app-agendamento-salao.firebaseapp.com',
      storageBucket: 'app-agendamento-salao.firebasestorage.app',
    ),
  );
  runApp(const SalonSchedulerApp());
}
