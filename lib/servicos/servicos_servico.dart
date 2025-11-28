import 'package:cloud_firestore/cloud_firestore.dart';

import '../modelos/servico.dart';

class ServicosServico {
  ServicosServico({
    required String userId,
    FirebaseFirestore? firestore,
  })  : _userId = userId,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final String _userId;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _colecao =>
      _firestore.collection('users').doc(_userId).collection('services');

  CollectionReference<Map<String, dynamic>> get _colecaoAgendamentos =>
      _firestore.collection('users').doc(_userId).collection('appointments');

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

  Future<int> contarAgendamentosComServico(String servicoId) async {
    final snapshot = await _colecaoAgendamentos.get();
    int contador = 0;
    for (final doc in snapshot.docs) {
      final dados = doc.data();
      final servicos = dados['servicos'];
      if (servicos is List) {
        for (final servico in servicos) {
          if (servico is Map && servico['id'] == servicoId) {
            contador++;
            break;
          }
        }
      }
    }
    return contador;
  }

  Future<void> excluirServico(String id) async {
    await _colecao.doc(id).delete();
  }
}
