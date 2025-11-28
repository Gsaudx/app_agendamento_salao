import 'package:flutter/material.dart';

class AppBarSecundario extends StatelessWidget implements PreferredSizeWidget {
  const AppBarSecundario({
    super.key,
    required this.titulo,
    this.icone,
  });

  final String titulo;
  final IconData? icone;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFFEC8C8),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFFCF7072),
            size: 18,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFCF7072).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icone,
                color: const Color(0xFFCF7072),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Text(
            titulo,
            style: const TextStyle(
              color: Color(0xFF5D4037),
              fontWeight: FontWeight.w600,
              fontSize: 18,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFEC8C8),
              Color(0xFFFDD9D9),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFCF7072).withOpacity(0.0),
                const Color(0xFFCF7072).withOpacity(0.3),
                const Color(0xFFCF7072).withOpacity(0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}
