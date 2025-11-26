import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageServico {
  StorageServico({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  /// Faz upload de uma imagem de perfil do cliente.
  /// Retorna a URL pública da imagem.
  Future<String> uploadFotoCliente({
    required String clienteId,
    required Uint8List bytes,
    required String extensao,
  }) async {
    final ref = _storage.ref().child('clientes/$clienteId/foto.$extensao');

    final metadata = SettableMetadata(
      contentType: _getContentType(extensao),
      customMetadata: {
        'uploadedAt': DateTime.now().toIso8601String(),
      },
    );

    final uploadTask = ref.putData(bytes, metadata);

    // Aguarda o upload completar
    await uploadTask;

    // Retorna a URL de download
    final url = await ref.getDownloadURL();
    return url;
  }

  /// Deleta a foto de perfil de um cliente.
  Future<void> deletarFotoCliente(String clienteId) async {
    try {
      // Tenta deletar possíveis extensões
      final extensoes = ['jpg', 'jpeg', 'png', 'webp'];
      for (final ext in extensoes) {
        try {
          final ref = _storage.ref().child('clientes/$clienteId/foto.$ext');
          await ref.delete();
        } catch (_) {
          // Ignora se o arquivo não existir
        }
      }
    } catch (e) {
      // Ignora erros de deleção
    }
  }

  String _getContentType(String extensao) {
    switch (extensao.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }
}
