import 'package:flutter/widgets.dart';

import '../servicos/agendamentos_servico.dart';
import '../servicos/autenticacao_servico.dart';
import '../servicos/clientes_servico.dart';
import '../servicos/servicos_servico.dart';

class DependenciasWidget extends InheritedWidget {
  const DependenciasWidget({
    super.key,
    required super.child,
    required this.autenticacao,
    required this.clientes,
    required this.servicos,
    required this.agendamentos,
  });

  final AutenticacaoServico autenticacao;
  final ClientesServico clientes;
  final ServicosServico servicos;
  final AgendamentosServico agendamentos;

  static AutenticacaoServico autenticacaoDe(BuildContext context) {
    final dependencias = context
        .dependOnInheritedWidgetOfExactType<DependenciasWidget>();
    assert(
      dependencias != null,
      'DependenciasWidget não encontrado no contexto.',
    );
    return dependencias!.autenticacao;
  }

  static ClientesServico clientesDe(BuildContext context) {
    final dependencias = context
        .dependOnInheritedWidgetOfExactType<DependenciasWidget>();
    assert(
      dependencias != null,
      'DependenciasWidget não encontrado no contexto.',
    );
    return dependencias!.clientes;
  }

  static ServicosServico servicosDe(BuildContext context) {
    final dependencias = context
        .dependOnInheritedWidgetOfExactType<DependenciasWidget>();
    assert(
      dependencias != null,
      'DependenciasWidget não encontrado no contexto.',
    );
    return dependencias!.servicos;
  }

  static AgendamentosServico agendamentosDe(BuildContext context) {
    final dependencias = context
        .dependOnInheritedWidgetOfExactType<DependenciasWidget>();
    assert(
      dependencias != null,
      'DependenciasWidget não encontrado no contexto.',
    );
    return dependencias!.agendamentos;
  }

  @override
  bool updateShouldNotify(covariant DependenciasWidget oldWidget) => false;
}
