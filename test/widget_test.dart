import 'package:app_paula_barros/app.dart';
import 'package:app_paula_barros/servicos/agendamentos_servico.dart';
import 'package:app_paula_barros/servicos/autenticacao_servico.dart';
import 'package:app_paula_barros/servicos/clientes_servico.dart';
import 'package:app_paula_barros/servicos/servicos_servico.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('exibe tela de login quando não autenticado', (tester) async {
    final autenticacaoMock = AutenticacaoServico(
      firebaseAuth: MockFirebaseAuth(),
    );
    final fakeFirestore = FakeFirebaseFirestore();
    await tester.pumpWidget(
      SalonSchedulerApp(
        autenticacaoServico: autenticacaoMock,
        clientesServico: ClientesServico(firestore: fakeFirestore),
        servicosServico: ServicosServico(firestore: fakeFirestore),
        agendamentosServico: AgendamentosServico(firestore: fakeFirestore),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Acesse sua conta'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
