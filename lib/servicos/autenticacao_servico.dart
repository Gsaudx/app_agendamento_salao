import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'web_client_id_stub.dart'
    if (dart.library.html) 'web_client_id.dart'
    as web_client;

class AutenticacaoServico {
  AutenticacaoServico({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn? _googleSignIn;

  User? get usuarioAtual => _firebaseAuth.currentUser;

  Stream<User?> get fluxoUsuario => _firebaseAuth.authStateChanges();

  Future<void> entrarEmailSenha({
    required String email,
    required String senha,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: senha,
    );
  }

  Future<UserCredential> cadastrarEmailSenha({
    required String email,
    required String senha,
  }) async {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: senha,
    );
  }

  Future<void> entrarGoogle() async {
    final google = _googleSignIn ?? _buildGoogleSignIn();
    final conta = await google.signIn();
    if (conta == null) {
      throw StateError('Autenticação cancelada pelo usuário.');
    }
    final autenticacao = await conta.authentication;
    final credencial = GoogleAuthProvider.credential(
      accessToken: autenticacao.accessToken,
      idToken: autenticacao.idToken,
    );
    await _firebaseAuth.signInWithCredential(credencial);
  }

  GoogleSignIn _buildGoogleSignIn() {
    // On web, the package requires a clientId. Try to read from meta tag.
    final clientId = web_client.readGoogleClientId();
    if (clientId != null && clientId.isNotEmpty) {
      return GoogleSignIn(
        clientId: clientId,
        scopes: <String>['email', 'profile'],
      );
    }
    // Otherwise return default (native/mobile) instance which works on Android/iOS.
    return GoogleSignIn(scopes: <String>['email', 'profile']);
  }

  Future<void> sair() async {
    await _firebaseAuth.signOut();
    try {
      await (_googleSignIn ?? GoogleSignIn()).signOut();
    } catch (_) {}
  }
}
