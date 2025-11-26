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

  Future<String> criarCliente({
    required String nome,
    required String telefone,
    String? email,
    DateTime? dataNascimento,
    String? observacoes,
    String? fotoUrl,
  }) async {
    final docRef = await _colecao.add({
      'nome': nome,
      'telefone': telefone,
      if (email != null && email.isNotEmpty) 'email': email,
      if (observacoes != null && observacoes.isNotEmpty)
        'observacoes': observacoes,
      if (dataNascimento != null)
        'dataNascimento': Timestamp.fromDate(dataNascimento),
      if (fotoUrl != null && fotoUrl.isNotEmpty) 'fotoUrl': fotoUrl,
      'criadoEm': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<void> atualizarCliente(
    String id, {
    required String nome,
    required String telefone,
    String? email,
    DateTime? dataNascimento,
    String? observacoes,
    String? fotoUrl,
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
    if (fotoUrl != null && fotoUrl.isNotEmpty) {
      dados['fotoUrl'] = fotoUrl;
    }
    await _colecao.doc(id).update(dados);
  }

  Future<void> atualizarFotoCliente(String id, String? fotoUrl) async {
    if (fotoUrl != null && fotoUrl.isNotEmpty) {
      await _colecao.doc(id).update({'fotoUrl': fotoUrl});
    } else {
      await _colecao.doc(id).update({'fotoUrl': FieldValue.delete()});
    }
  }
}
