import 'package:flutter/material.dart';

enum TipoDialogo { confirmacao, alerta, erro, sucesso }

class DialogConfirmacao extends StatelessWidget {
  const DialogConfirmacao({
    super.key,
    required this.titulo,
    required this.mensagem,
    this.tipo = TipoDialogo.confirmacao,
    this.textoBotaoConfirmar,
    this.textoBotaoCancelar = 'Cancelar',
    this.onConfirmar,
    this.onCancelar,
    this.mostrarBotaoCancelar = true,
  });

  final String titulo;
  final String mensagem;
  final TipoDialogo tipo;
  final String? textoBotaoConfirmar;
  final String textoBotaoCancelar;
  final VoidCallback? onConfirmar;
  final VoidCallback? onCancelar;
  final bool mostrarBotaoCancelar;

  static Future<bool> mostrar({
    required BuildContext context,
    required String titulo,
    required String mensagem,
    TipoDialogo tipo = TipoDialogo.confirmacao,
    String? textoBotaoConfirmar,
    String textoBotaoCancelar = 'Cancelar',
    bool mostrarBotaoCancelar = true,
  }) async {
    final resultado = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fechar',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return DialogConfirmacao(
          titulo: titulo,
          mensagem: mensagem,
          tipo: tipo,
          textoBotaoConfirmar: textoBotaoConfirmar,
          textoBotaoCancelar: textoBotaoCancelar,
          mostrarBotaoCancelar: mostrarBotaoCancelar,
          onConfirmar: () => Navigator.of(context).pop(true),
          onCancelar: () => Navigator.of(context).pop(false),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
    return resultado ?? false;
  }

  IconData get _icone {
    switch (tipo) {
      case TipoDialogo.confirmacao:
        return Icons.help_outline_rounded;
      case TipoDialogo.alerta:
        return Icons.warning_amber_rounded;
      case TipoDialogo.erro:
        return Icons.error_outline_rounded;
      case TipoDialogo.sucesso:
        return Icons.check_circle_outline_rounded;
    }
  }

  Color get _corPrincipal {
    switch (tipo) {
      case TipoDialogo.confirmacao:
      case TipoDialogo.alerta:
        return const Color(0xFFCF7072);
      case TipoDialogo.erro:
        return Colors.red;
      case TipoDialogo.sucesso:
        return Colors.green;
    }
  }

  Color get _corFundoIcone {
    switch (tipo) {
      case TipoDialogo.confirmacao:
      case TipoDialogo.alerta:
        return const Color(0xFFFEC8C8);
      case TipoDialogo.erro:
        return Colors.red.shade50;
      case TipoDialogo.sucesso:
        return Colors.green.shade50;
    }
  }

  String get _textoBotaoConfirmarPadrao {
    switch (tipo) {
      case TipoDialogo.confirmacao:
        return 'Confirmar';
      case TipoDialogo.alerta:
        return 'Entendi';
      case TipoDialogo.erro:
        return 'Entendi';
      case TipoDialogo.sucesso:
        return 'OK';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 24),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _corFundoIcone,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _icone,
                    size: 40,
                    color: _corPrincipal,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    mensagem,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Row(
                    children: [
                      if (mostrarBotaoCancelar) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onCancelar,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey[700],
                              side: BorderSide(color: Colors.grey[300]!),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              textoBotaoCancelar,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onConfirmar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _corPrincipal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            textoBotaoConfirmar ?? _textoBotaoConfirmarPadrao,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
