import 'package:cloud_firestore/cloud_firestore.dart';

class Cliente {
  Cliente({
    required this.id,
    required this.nome,
    required this.telefone,
    this.email,
    this.observacoes,
    this.dataNascimento,
  });

  final String id;
  final String nome;
  final String telefone;
  final String? email;
  final String? observacoes;
  final DateTime? dataNascimento;

  factory Cliente.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> documento,
  ) {
    final dados = documento.data();
    if (dados == null) {
      throw StateError('Documento de cliente vazio para id ${documento.id}');
    }
    DateTime? dataNascimento;
    final nascimento = dados['dataNascimento'];
    if (nascimento is Timestamp) {
      dataNascimento = nascimento.toDate();
    } else if (nascimento is DateTime) {
      dataNascimento = nascimento;
    }
    return Cliente(
      id: documento.id,
      nome: (dados['nome'] as String?)?.trim() ?? 'Cliente sem nome',
      telefone: (dados['telefone'] as String?)?.trim() ?? '',
      email: (dados['email'] as String?)?.trim(),
      observacoes: (dados['observacoes'] as String?)?.trim(),
      dataNascimento: dataNascimento,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'telefone': telefone,
      if (email != null) 'email': email,
      if (observacoes != null) 'observacoes': observacoes,
      if (dataNascimento != null)
        'dataNascimento': Timestamp.fromDate(dataNascimento!),
    };
  }
}
