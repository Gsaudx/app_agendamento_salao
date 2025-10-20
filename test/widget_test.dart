import 'package:app_paula_barros/app.dart';
import 'package:app_paula_barros/servicos/autenticacao_servico.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('exibe tela de login quando não autenticado', (tester) async {
    final autenticacaoMock = AutenticacaoServico(firebaseAuth: MockFirebaseAuth());
    await tester.pumpWidget(SalonSchedulerApp(autenticacaoServico: autenticacaoMock));
    await tester.pumpAndSettle();
    expect(find.text('Acesse sua conta'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
