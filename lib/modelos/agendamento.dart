import 'package:cloud_firestore/cloud_firestore.dart';

class Agendamento {
  Agendamento({
    required this.id,
    required this.inicio,
    required this.duracaoMinutos,
    required this.clienteNome,
    required this.servicoNome,
    this.preco,
    this.observacoes,
  });

  final String id;
  final DateTime inicio;
  final int duracaoMinutos;
  final String clienteNome;
  final String servicoNome;
  final double? preco;
  final String? observacoes;

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
    final precoBruto = dados['preco'];
    return Agendamento(
      id: documento.id,
      inicio: inicio,
      duracaoMinutos: (dados['duracaoMinutos'] as num?)?.toInt() ?? 30,
      clienteNome: (dados['clienteNome'] as String?)?.trim() ?? 'Cliente',
      servicoNome: (dados['servicoNome'] as String?)?.trim() ?? 'Serviço',
      preco: precoBruto is num ? precoBruto.toDouble() : null,
      observacoes: (dados['observacoes'] as String?)?.trim(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'inicio': Timestamp.fromDate(inicio),
      'duracaoMinutos': duracaoMinutos,
      'clienteNome': clienteNome,
      'servicoNome': servicoNome,
      if (preco != null) 'preco': preco,
      if (observacoes != null) 'observacoes': observacoes,
    };
  }
}
