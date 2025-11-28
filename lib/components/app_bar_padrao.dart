import 'package:flutter/material.dart';

import '../dependencias/dependencias_widget.dart';

class AppBarPadrao extends StatelessWidget implements PreferredSizeWidget {
  const AppBarPadrao({
    super.key,
    this.leading,
    this.mostrarLogout = true,
  });

  final Widget? leading;
  final bool mostrarLogout;

  Future<void> _sair(BuildContext context) async {
    try {
      final autenticacao = DependenciasWidget.autenticacaoDe(context);
      debugPrint('Iniciando logout...');
      await autenticacao.sair();
      debugPrint('Logout concluído com sucesso');
    } catch (e) {
      debugPrint('Erro no logout: $e');
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
