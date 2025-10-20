import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AutenticacaoServico {
  AutenticacaoServico({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn? _googleSignIn;

  User? get usuarioAtual => _firebaseAuth.currentUser;

  Stream<User?> get fluxoUsuario => _firebaseAuth.authStateChanges();

  Future<void> entrarEmailSenha({required String email, required String senha}) async {
    await _firebaseAuth.signInWithEmailAndPassword(email: email, password: senha);
  }

  Future<void> cadastrarEmailSenha({required String email, required String senha}) async {
    await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: senha);
  }

  Future<void> entrarGoogle() async {
    final google = _googleSignIn ?? GoogleSignIn();
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

  Future<void> sair() async {
    await _firebaseAuth.signOut();
    try {
      await (_googleSignIn ?? GoogleSignIn()).signOut();
    } catch (_) {}
  }
}
