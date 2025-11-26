import 'package:flutter/material.dart';

import '../dependencias/dependencias_widget.dart';
import '../screens/login_screen.dart';

class AppBarPadrao extends StatelessWidget implements PreferredSizeWidget {
  const AppBarPadrao({
    super.key,
    this.leading,
    this.mostrarLogout = true,
  });

  final Widget? leading;
  final bool mostrarLogout;

  Future<void> _sair(BuildContext context) async {
    final navigator = Navigator.of(context);
    final mensageiro = ScaffoldMessenger.of(context);
    try {
      final autenticacao = DependenciasWidget.autenticacaoDe(context);
      await autenticacao.sair();
      navigator.pushNamedAndRemoveUntil(LoginScreen.routeName, (_) => false);
    } catch (erro) {
      mensageiro.showSnackBar(
        SnackBar(content: Text('Não foi possível sair: $erro')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFFEC8C8),
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: leading,
      title: Image.asset(
        'assets/img/logo_paula_barros.png',
        height: 50,
      ),
      actions: mostrarLogout
          ? [
              IconButton(
                tooltip: 'Sair',
                onPressed: () => _sair(context),
                icon: const Icon(Icons.logout, color: Colors.black54),
              ),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
