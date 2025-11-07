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
    required String clienteId,
    required String clienteNome,
    required DateTime inicio,
    required DateTime fim,
    required List<AgendamentoServicoResumo> servicos,
    required double total,
    String? observacoes,
  }) async {
    final servicosMap = servicos.map((servico) => servico.toMap()).toList();
    final duracaoMinutos = servicos.fold<int>(
      0,
      (total, servico) => total + servico.duracaoMinutos,
    );
    final descricaoServicos = servicos
        .map((servico) => servico.nome)
        .join(', ');
    await _colecao.add({
      'clienteId': clienteId,
      'clienteNome': clienteNome,
      'inicio': Timestamp.fromDate(inicio),
      'fim': Timestamp.fromDate(fim),
      'duracaoMinutos': duracaoMinutos,
      'servicos': servicosMap,
      'total': total,
      'preco': total,
      'servicoNome': descricaoServicos,
      if (observacoes != null && observacoes.isNotEmpty)
        'observacoes': observacoes,
      'criadoEm': FieldValue.serverTimestamp(),
    });
  }
}
