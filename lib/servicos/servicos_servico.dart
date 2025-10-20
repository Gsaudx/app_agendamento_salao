import 'package:cloud_firestore/cloud_firestore.dart';

import '../modelos/servico.dart';

class ServicosServico {
  ServicosServico({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _colecao =>
      _firestore.collection('services');

  Stream<List<Servico>> observarServicos() {
    return _colecao
        .where('ativo', isNotEqualTo: false)
        .orderBy('nome')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Servico.fromDocument).toList());
  }

  Future<void> criarServico({
    required String nome,
    required int duracaoMinutos,
    required double preco,
    String? descricao,
  }) async {
    await _colecao.add({
      'nome': nome,
      'duracaoMinutos': duracaoMinutos,
      'preco': preco,
      if (descricao != null && descricao.isNotEmpty) 'descricao': descricao,
      'ativo': true,
      'criadoEm': FieldValue.serverTimestamp(),
    });
  }

  Future<void> atualizarServico(
    String id, {
    required String nome,
    required int duracaoMinutos,
    required double preco,
    String? descricao,
    bool? ativo,
  }) async {
    await _colecao.doc(id).update({
      'nome': nome,
      'duracaoMinutos': duracaoMinutos,
      'preco': preco,
      'descricao': descricao?.isNotEmpty == true
          ? descricao
          : FieldValue.delete(),
      if (ativo != null) 'ativo': ativo,
    });
  }
}
