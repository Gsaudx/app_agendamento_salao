import 'package:cloud_firestore/cloud_firestore.dart';

class Agendamento {
  Agendamento({
    required this.id,
    required this.clienteId,
    required this.clienteNome,
    required this.inicio,
    this.fim,
    required this.duracaoMinutos,
    required this.servicos,
    required this.total,
    this.observacoes,
  });

  final String id;
  final String clienteId;
  final String clienteNome;
  final DateTime inicio;
  final DateTime? fim;
  final int duracaoMinutos;
  final List<AgendamentoServicoResumo> servicos;
  final double total;
  final String? observacoes;

  String get descricaoServicos => servicos
      .map((servico) => servico.nome)
      .where((n) => n.isNotEmpty)
      .join(', ');

  factory Agendamento.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> documento,
  ) {
    final dados = documento.data();
    if (dados == null) {
      throw StateError(
        'Documento de agendamento vazio para id ${documento.id}',
      );
    }
    final inicioCampo = dados['inicio'];
    late final DateTime inicio;
    if (inicioCampo is Timestamp) {
      inicio = inicioCampo.toDate();
    } else if (inicioCampo is DateTime) {
      inicio = inicioCampo;
    } else {
      throw StateError(
        'Campo "inicio" inválido no agendamento ${documento.id}',
      );
    }
    DateTime? fim;
    final fimCampo = dados['fim'];
    if (fimCampo is Timestamp) {
      fim = fimCampo.toDate();
    } else if (fimCampo is DateTime) {
      fim = fimCampo;
    }

    final servicosBrutos = dados['servicos'];
    List<AgendamentoServicoResumo> servicos;
    if (servicosBrutos is List) {
      servicos = servicosBrutos
          .map((item) {
            if (item is Map<String, dynamic>) {
              return AgendamentoServicoResumo.fromMap(item);
            }
            if (item is Map) {
              return AgendamentoServicoResumo.fromMap(
                item.map((key, value) => MapEntry(key.toString(), value)),
              );
            }
            return null;
          })
          .whereType<AgendamentoServicoResumo>()
          .toList();
    } else {
      final precoUnicoBruto = dados['preco'];
      final precoUnico = precoUnicoBruto is num
          ? precoUnicoBruto.toDouble()
          : 0.0;
      servicos = [
        AgendamentoServicoResumo(
          id: (dados['servicoId'] as String?) ?? '',
          nome: (dados['servicoNome'] as String?)?.trim() ?? 'Serviço',
          duracaoMinutos: (dados['duracaoMinutos'] as num?)?.toInt() ?? 0,
          preco: precoUnico,
        ),
      ];
    }

    final precoBruto = dados['total'] ?? dados['preco'];
    return Agendamento(
      id: documento.id,
      clienteId: (dados['clienteId'] as String?) ?? '',
      clienteNome: (dados['clienteNome'] as String?)?.trim() ?? 'Cliente',
      inicio: inicio,
      fim: fim,
      duracaoMinutos:
          (dados['duracaoMinutos'] as num?)?.toInt() ??
          servicos.fold<int>(
            0,
            (total, servico) => total + servico.duracaoMinutos,
          ),
      servicos: servicos,
      total: precoBruto is num
          ? precoBruto.toDouble()
          : servicos.fold<double>(0, (total, servico) => total + servico.preco),
      observacoes: (dados['observacoes'] as String?)?.trim(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'clienteNome': clienteNome,
      'inicio': Timestamp.fromDate(inicio),
      if (fim != null) 'fim': Timestamp.fromDate(fim!),
      'duracaoMinutos': duracaoMinutos,
      'servicos': servicos.map((servico) => servico.toMap()).toList(),
      'total': total,
      'preco': total,
      'servicoNome': descricaoServicos,
      if (observacoes != null) 'observacoes': observacoes,
    };
  }
}

class AgendamentoServicoResumo {
  AgendamentoServicoResumo({
    required this.id,
    required this.nome,
    required this.duracaoMinutos,
    required this.preco,
  });

  final String id;
  final String nome;
  final int duracaoMinutos;
  final double preco;

  factory AgendamentoServicoResumo.fromMap(Map<String, dynamic> dados) {
    return AgendamentoServicoResumo(
      id: (dados['id'] as String?) ?? '',
      nome: (dados['nome'] as String?)?.trim() ?? 'Serviço',
      duracaoMinutos: (dados['duracaoMinutos'] as num?)?.toInt() ?? 0,
      preco: (dados['preco'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'duracaoMinutos': duracaoMinutos,
      'preco': preco,
    };
  }
}
