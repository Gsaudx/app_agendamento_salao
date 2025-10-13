# app_paula_barros

> Aplicativo Flutter simples para controle de agendamentos do Salão Paula Barros. O objetivo é ser fácil de entender, modificar e apresentar no projeto interdisciplinar.

## Tecnologias

- **Flutter** (Material 3) com **Dart 3.9**
- Navegação com rotas nomeadas padrão (`MaterialApp.routes`)
- Telas estáticas com dados fictícios (integração futura com Firebase)

## Estrutura atual

```
lib/
├── app.dart           → Configuração do `MaterialApp` e tema
├── main.dart          → Função `main()` que inicia o app
└── screens/           → Telas estáticas do projeto
		├── home_screen.dart
		├── appointments_screen.dart
		├── clients_screen.dart
		└── services_screen.dart
```

O teste de interface em `test/widget_test.dart` garante que a tela inicial continue exibindo os principais elementos.

## Como rodar
```powershell
flutter pub get
flutter run
```

## Como testar
```powershell
flutter test
```

## Como criar uma nova tela
1. Crie um arquivo em `lib/screens/<nome>_screen.dart`.
2. Declare um `StatelessWidget` (ou `StatefulWidget`, se precisar de estado local) e defina uma constante `routeName`.
3. Registre a nova rota no mapa `routes` de `SalonSchedulerApp` em `lib/app.dart`.
4. Use `Navigator.pushNamed(context, NovaTela.routeName)` a partir de qualquer lugar do app.

Exemplo mínimo:

```dart
// lib/screens/example_screen.dart
import 'package:flutter/material.dart';

class ExampleScreen extends StatelessWidget {
	const ExampleScreen({super.key});

	static const routeName = '/example';

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Exemplo')),
			body: const Center(child: Text('Nova tela')),
		);
	}
}
```

Depois, edite `app.dart`:

```dart
import 'screens/example_screen.dart';

routes: {
	...
	ExampleScreen.routeName: (context) => const ExampleScreen(),
},
```

Com isso, você pode navegar usando `Navigator.pushNamed(context, ExampleScreen.routeName);`.
