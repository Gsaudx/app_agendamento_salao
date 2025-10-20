# app_paula_barros

Aplicativo Flutter para gerenciamento do Salão Paula Barros. O projeto combina Material 3 com autenticação Firebase, integrações em tempo real com Cloud Firestore e fluxos básicos de clientes, serviços e agenda.

## Visão Geral

- Flutter 3.24+ (Dart 3.9) com Material 3 e rotas nomeadas.
- Firebase Authentication (e-mail/senha + Google) e Cloud Firestore para dados.
- Interface responsiva focada em desktop/web com cartões, listas e máscaras de entrada.
- Injeção de dependências via `DependenciasWidget` para facilitar testes e mocks.
- Testes de widget usando `fake_cloud_firestore` e `firebase_auth_mocks`.

## Funcionalidades

- Login e cadastro com e-mail/senha; suporte a login com Google (inclui ajuste de `client_id` para web).
- Dashboard com saudação personalizada e pré-visualização dos próximos agendamentos.
- Listagem de agendamentos com data/hora formatadas (`intl`) e destaque do valor.
- CRUD básico de clientes com máscara de telefone e campos opcionais (nascimento, observações).
- Catálogo de serviços com duração, preço (máscara de moeda) e CTA para agendamento.
- Componentes reutilizáveis (`Input`, `Button`, `FloatingButton`, `Select`) e formatadores customizados.

## Estrutura do Projeto

```
lib/
├── app.dart                 # MaterialApp, tema e rotas nomeadas
├── main.dart                # Bootstrap e inicialização do Firebase
├── components/              # Inputs, botões e elementos de UI
├── dependencias/            # InheritedWidget para fornecer serviços
├── formatters/              # Máscaras para moeda e telefone
├── modelos/                 # Modelos (cliente, serviço, agendamento)
├── screens/                 # Telas principais (login, home, clientes, serviços...)
└── servicos/                # Camada de acesso ao Firebase (auth, Firestore)
test/
└── widget_test.dart         # Garantia de fluxo de login quando não autenticado
web/
└── index.html               # Meta tag do Google Sign-In (client_id)
```

## Pré-requisitos

- Flutter 3.24.x+ (`flutter --version`).
- Conta Firebase com Authentication e Cloud Firestore habilitados.
- Para web: projeto OAuth 2.0 com domínio registrado e `client_id` liberado.

## Configuração do Firebase

1. **Projeto Firebase**: crie um projeto e habilite provedores de e-mail/senha e Google em Authentication.
2. **Firestore**: crie as coleções `appointments`, `clients` e `services` (as estruturas são definidas pelos serviços).
3. **Credenciais**:
   - O app inicializa o Firebase diretamente em `lib/main.dart` usando `FirebaseOptions`. Atualize esses valores com as credenciais do seu projeto.
   - Alternativa recomendada: execute `flutterfire configure` e substitua a inicialização manual por `DefaultFirebaseOptions.currentPlatform`. Guarde as chaves fora do controle de versão.
   - `.env.example` documenta os campos necessários caso opte por carregar variáveis de ambiente via outro mecanismo.
4. **Login Google (Web)**: atualize `web/index.html` com o `client_id` do OAuth Web no meta `google-signin-client_id`.

## Como Executar

```powershell
flutter pub get
flutter run --device-id chrome   # ou outro device disponível
```

Observações:

- Garanta que o Flutter Web esteja habilitado (`flutter config --enable-web`).
- Para Android/iOS, configure `google-services.json` / `GoogleService-Info.plist` normalmente.
- Caso use conta Google no web, acesse pelo domínio autorizado no console Firebase.

## Testes

```powershell
flutter test
```

O teste principal valida se a tela de login aparece quando não há usuário autenticado, utilizando fakes de Firebase.

## Coleções do Firestore

- `clients`: `nome`, `telefone`, `email?`, `dataNascimento?`, `observacoes?`, `criadoEm`.
- `services`: `nome`, `duracaoMinutos`, `preco`, `descricao?`, `ativo`, `criadoEm`.
- `appointments`: `inicio`, `duracaoMinutos`, `clienteNome`, `servicoNome`, `preco?`, `observacoes?`, `criadoEm`.

## Comandos Úteis

- `flutter pub upgrade` – atualizar dependências.
- `flutter analyze` – executar análise estática (usa regras do `analysis_options.yaml`).
- `flutterfire configure` – gerar `firebase_options.dart` oficial.