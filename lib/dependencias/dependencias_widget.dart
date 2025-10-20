import 'package:flutter/widgets.dart';

import '../servicos/autenticacao_servico.dart';

class DependenciasWidget extends InheritedWidget {
  const DependenciasWidget({
    super.key,
    required super.child,
    required this.autenticacao,
  });

  final AutenticacaoServico autenticacao;

  static AutenticacaoServico autenticacaoDe(BuildContext context) {
    final dependencias = context
        .dependOnInheritedWidgetOfExactType<DependenciasWidget>();
    assert(
      dependencias != null,
      'DependenciasWidget não encontrado no contexto.',
    );
    return dependencias!.autenticacao;
  }

  @override
  bool updateShouldNotify(covariant DependenciasWidget oldWidget) => false;
}
