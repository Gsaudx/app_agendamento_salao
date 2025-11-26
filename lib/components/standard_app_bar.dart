import 'package:flutter/material.dart';
import '../dependencias/dependencias_widget.dart';
import '../screens/login_screen.dart';

class StandardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const StandardAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFFEC8C8),
      elevation: 0,
      centerTitle: true,
      title: Image.asset(
        'assets/img/logo_paula_barros.png',
        height: 40,
        fit: BoxFit.contain,
      ),
      iconTheme: const IconThemeData(color: Color(0xFF5D4037)),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            final autenticacao = DependenciasWidget.autenticacaoDe(context);
            await autenticacao.sair();
            if (context.mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                LoginScreen.routeName,
                (route) => false,
              );
            }
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
