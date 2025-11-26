import 'package:flutter/material.dart';

class AppBarPadrao extends StatelessWidget implements PreferredSizeWidget {
  const AppBarPadrao({
    super.key,
    this.onLogout,
    this.leading,
  });

  final VoidCallback? onLogout;
  final Widget? leading;

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
      actions: onLogout != null
          ? [
              IconButton(
                tooltip: 'Sair',
                onPressed: onLogout,
                icon: const Icon(Icons.logout, color: Colors.black54),
              ),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
