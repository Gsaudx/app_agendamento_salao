import 'package:app_paula_barros/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('initial route shows home dashboard', (tester) async {
    await tester.pumpWidget(const SalonSchedulerApp());
    await tester.pumpAndSettle();
    expect(find.text('Agenda do Salão'), findsOneWidget);
    expect(find.text('Próximos agendamentos'), findsOneWidget);
  });
}
