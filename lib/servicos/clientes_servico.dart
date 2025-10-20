import 'package:cloud_firestore/cloud_firestore.dart';

import '../modelos/cliente.dart';

class ClientesServico {
  ClientesServico({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _colecao =>
      _firestore.collection('clients');

  Stream<List<Cliente>> observarClientes() {
    return _colecao
        .orderBy('nome')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Cliente.fromDocument).toList());
  }

  Future<void> criarCliente({
    required String nome,
    required String telefone,
    String? email,
    DateTime? dataNascimento,
    String? observacoes,
  }) async {
    await _colecao.add({
      'nome': nome,
      'telefone': telefone,
      if (email != null && email.isNotEmpty) 'email': email,
      if (observacoes != null && observacoes.isNotEmpty)
        'observacoes': observacoes,
      if (dataNascimento != null)
        'dataNascimento': Timestamp.fromDate(dataNascimento),
      'criadoEm': FieldValue.serverTimestamp(),
    });
  }

  Future<void> atualizarCliente(
    String id, {
    required String nome,
    required String telefone,
    String? email,
    DateTime? dataNascimento,
    String? observacoes,
  }) async {
    final dados = <String, dynamic>{
      'nome': nome,
      'telefone': telefone,
      'email': email?.isNotEmpty == true ? email : FieldValue.delete(),
      'observacoes': observacoes?.isNotEmpty == true
          ? observacoes
          : FieldValue.delete(),
    };
    if (dataNascimento != null) {
      dados['dataNascimento'] = Timestamp.fromDate(dataNascimento);
    } else {
      dados['dataNascimento'] = FieldValue.delete();
    }
    await _colecao.doc(id).update(dados);
  }
}
