import 'package:flutter/widgets.dart';

import '../servicos/agendamentos_servico.dart';
import '../servicos/autenticacao_servico.dart';
import '../servicos/clientes_servico.dart';
import '../servicos/servicos_servico.dart';
import '../servicos/storage_servico.dart';

class DependenciasWidget extends InheritedWidget {
  const DependenciasWidget({
    super.key,
    required super.child,
    required this.autenticacao,
    this.clientes,
    this.servicos,
    this.agendamentos,
    this.storage,
  });

  final AutenticacaoServico autenticacao;
  final ClientesServico? clientes;
  final ServicosServico? servicos;
  final AgendamentosServico? agendamentos;
  final StorageServico? storage;

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
    assert(
      dependencias!.clientes != null,
      'ClientesServico não disponível. Usuário não está logado.',
    );
    return dependencias!.clientes!;
  }

  static ServicosServico servicosDe(BuildContext context) {
    final dependencias = context
        .dependOnInheritedWidgetOfExactType<DependenciasWidget>();
    assert(
      dependencias != null,
      'DependenciasWidget não encontrado no contexto.',
    );
    assert(
      dependencias!.servicos != null,
      'ServicosServico não disponível. Usuário não está logado.',
    );
    return dependencias!.servicos!;
  }

  static AgendamentosServico agendamentosDe(BuildContext context) {
    final dependencias = context
        .dependOnInheritedWidgetOfExactType<DependenciasWidget>();
    assert(
      dependencias != null,
      'DependenciasWidget não encontrado no contexto.',
    );
    assert(
      dependencias!.agendamentos != null,
      'AgendamentosServico não disponível. Usuário não está logado.',
    );
    return dependencias!.agendamentos!;
  }

  static StorageServico storageDe(BuildContext context) {
    final dependencias = context
        .dependOnInheritedWidgetOfExactType<DependenciasWidget>();
    assert(
      dependencias != null,
      'DependenciasWidget não encontrado no contexto.',
    );
    assert(
      dependencias!.storage != null,
      'StorageServico não disponível. Usuário não está logado.',
    );
    return dependencias!.storage!;
  }

  @override
  bool updateShouldNotify(covariant DependenciasWidget oldWidget) {
    return clientes != oldWidget.clientes ||
        servicos != oldWidget.servicos ||
        agendamentos != oldWidget.agendamentos ||
        storage != oldWidget.storage;
  }
}
