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

  Stream<List<Agendamento>> observarHistorico({
    DateTime? inicio,
    DateTime? fim,
    String? clienteId,
  }) {
    Query<Map<String, dynamic>> consulta = _colecao;

    if (clienteId != null) {
      consulta = consulta.where('clienteId', isEqualTo: clienteId);
    }

    if (inicio != null) {
      consulta = consulta.where(
        'inicio',
        isGreaterThanOrEqualTo: Timestamp.fromDate(inicio),
      );
    }

    if (fim != null) {
      final fimAjustado = DateTime(fim.year, fim.month, fim.day, 23, 59, 59);
      consulta = consulta.where(
        'inicio',
        isLessThanOrEqualTo: Timestamp.fromDate(fimAjustado),
      );
    }

    consulta = consulta.orderBy('inicio', descending: true);

    return consulta.snapshots().map(
      (snapshot) => snapshot.docs.map(Agendamento.fromDocument).toList(),
    );
  }

  Future<Agendamento?> verificarConflito({
    required DateTime inicio,
    required DateTime fim,
    String? ignorarId,
  }) async {
    final startOfDay = DateTime(inicio.year, inicio.month, inicio.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _colecao
        .where('inicio', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('inicio', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    final agendamentosDoDia = snapshot.docs.map(Agendamento.fromDocument);

    for (final agendamento in agendamentosDoDia) {
      if (ignorarId != null && agendamento.id == ignorarId) {
        continue;
      }

      final agendamentoFim =
          agendamento.fim ??
          agendamento.inicio.add(Duration(minutes: agendamento.duracaoMinutos));

      if (inicio.isBefore(agendamentoFim) && fim.isAfter(agendamento.inicio)) {
        return agendamento;
      }
    }
    return null;
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

  Future<void> atualizarAgendamento({
    required String id,
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
      (totalDuracao, servico) => totalDuracao + servico.duracaoMinutos,
    );
    final descricaoServicos = servicos
        .map((servico) => servico.nome)
        .join(', ');

    final dadosAtualizados = <String, dynamic>{
      'clienteId': clienteId,
      'clienteNome': clienteNome,
      'inicio': Timestamp.fromDate(inicio),
      'fim': Timestamp.fromDate(fim),
      'duracaoMinutos': duracaoMinutos,
      'servicos': servicosMap,
      'total': total,
      'preco': total,
      'servicoNome': descricaoServicos,
      'atualizadoEm': FieldValue.serverTimestamp(),
    };

    if (observacoes != null && observacoes.isNotEmpty) {
      dadosAtualizados['observacoes'] = observacoes;
    } else {
      dadosAtualizados['observacoes'] = FieldValue.delete();
    }

    await _colecao.doc(id).update(dadosAtualizados);
  }

  Future<void> cancelarAgendamento(String id) async {
    await _colecao.doc(id).delete();
  }
}
