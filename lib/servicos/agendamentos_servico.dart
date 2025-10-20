import 'package:cloud_firestore/cloud_firestore.dart';

import '../modelos/agendamento.dart';

class AgendamentosServico {
  AgendamentosServico({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _colecao =>
      _firestore.collection('appointments');

  Stream<List<Agendamento>> observarAgenda({bool apenasFuturos = true}) {
    Query<Map<String, dynamic>> consulta = _colecao.orderBy(
      'inicio',
      descending: false,
    );
    if (apenasFuturos) {
      consulta = consulta.where(
        'inicio',
        isGreaterThanOrEqualTo: Timestamp.fromDate(
          DateTime.now().subtract(const Duration(hours: 1)),
        ),
      );
    }
    return consulta.snapshots().map(
      (snapshot) => snapshot.docs.map(Agendamento.fromDocument).toList(),
    );
  }

  Stream<List<Agendamento>> observarProximos({int limite = 5}) {
    return _colecao
        .orderBy('inicio')
        .where(
          'inicio',
          isGreaterThanOrEqualTo: Timestamp.fromDate(
            DateTime.now().subtract(const Duration(hours: 1)),
          ),
        )
        .limit(limite)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(Agendamento.fromDocument).toList(),
        );
  }

  Future<void> criarAgendamento({
    required DateTime inicio,
    required int duracaoMinutos,
    required String clienteNome,
    required String servicoNome,
    double? preco,
    String? observacoes,
  }) async {
    await _colecao.add({
      'inicio': Timestamp.fromDate(inicio),
      'duracaoMinutos': duracaoMinutos,
      'clienteNome': clienteNome,
      'servicoNome': servicoNome,
      if (preco != null) 'preco': preco,
      if (observacoes != null && observacoes.isNotEmpty)
        'observacoes': observacoes,
      'criadoEm': FieldValue.serverTimestamp(),
    });
  }
}
