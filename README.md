# FirebaseApp - Flutter Counter Starter

Este é um projeto Flutter padrão com a estrutura clássica de demonstração do contador (Material Design 3), pronto para ser executado no Flutter SDK ou integrado ao Firebase.

## 📁 Estrutura do Projeto

```text
firebase_app/
├── lib/
│   └── main.dart          # Ponto de entrada com o widget MaterialApp e MyHomePage (Contador)
├── pubspec.yaml           # Manifesto de dependências e metadados do projeto
├── analysis_options.yaml  # Configurações do linter oficial do Flutter
└── README.md              # Documentação do projeto
```

## 🚀 Como Executar

1. Certifique-se de ter o Flutter instalado (`flutter --version`).
2. Instale as dependências:
   ```bash
   flutter pub get
   ```
3. Execute o aplicativo em seu emulador ou dispositivo conectado:
   ```bash
   flutter run
   ```

## 🔥 Como Integrar o Firebase (Opcional)

Para adicionar o Firebase posteriormente a este projeto:

1. Instale o FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
2. Configure o Firebase no projeto:
   ```bash
   flutterfire configure
   ```
3. Adicione os pacotes no `pubspec.yaml`:
   ```bash
   flutter pub add firebase_core
   ```
