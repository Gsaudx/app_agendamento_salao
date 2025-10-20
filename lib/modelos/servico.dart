import 'package:cloud_firestore/cloud_firestore.dart';

class Servico {
  Servico({
    required this.id,
    required this.nome,
    required this.duracaoMinutos,
    required this.preco,
    this.descricao,
    this.ativo = true,
  });

  final String id;
  final String nome;
  final int duracaoMinutos;
  final double preco;
  final String? descricao;
  final bool ativo;

  factory Servico.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> documento,
  ) {
    final dados = documento.data();
    if (dados == null) {
      throw StateError('Documento de serviço vazio para id ${documento.id}');
    }
    final precoBruto = dados['preco'];
    return Servico(
      id: documento.id,
      nome: (dados['nome'] as String?)?.trim() ?? 'Serviço sem nome',
      duracaoMinutos: (dados['duracaoMinutos'] as num?)?.toInt() ?? 30,
      preco: precoBruto is num ? precoBruto.toDouble() : 0,
      descricao: (dados['descricao'] as String?)?.trim(),
      ativo: (dados['ativo'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'duracaoMinutos': duracaoMinutos,
      'preco': preco,
      if (descricao != null) 'descricao': descricao,
      'ativo': ativo,
    };
  }

  String get duracaoFormatada {
    if (duracaoMinutos % 60 == 0) {
      final horas = duracaoMinutos ~/ 60;
      return horas == 1 ? '1h' : '${horas.toString()}h';
    }
    final horas = duracaoMinutos ~/ 60;
    final minutos = duracaoMinutos % 60;
    if (horas == 0) {
      return '${minutos.toString()} min';
    }
    return '${horas.toString()}h${minutos.toString().padLeft(2, '0')}';
  }
}
