# 4Ward — Mobile

Aplicativo mobile do **4Ward**, uma plataforma para conectar pacientes e fisioterapeutas. Esta versão é voltada ao **paciente**: permite buscar profissionais, agendar consultas e acompanhar o histórico. A criação de horários e a gestão da agenda são feitas pelo fisioterapeuta na versão web.

## Tecnologias

- Flutter
- Dart
- Material 3
- http
- flutter_secure_storage

## Pré-requisitos

Antes de iniciar, tenha instalado:

- Flutter SDK
- Android Studio (com Android SDK, NDK e um emulador) ou um celular com depuração USB

Também é necessário que o **backend do 4Ward** esteja em execução em:

```text
http://localhost:3000/api
```

## Instalação

Clone o repositório e acesse a pasta do projeto:

```bash
git clone <URL_DO_REPOSITORIO>
cd 4Ward-Mobile
```

Instale as dependências:

```bash
flutter pub get
```

## Executar o projeto

Inicie o aplicativo em um emulador ou dispositivo conectado:

```bash
flutter run
```

No emulador Android, o app acessa o backend em:

```text
http://10.0.2.2:3000/api
```

Em um celular físico (na mesma rede do computador), informe o IP da máquina:

```bash
flutter run --dart-define=API_URL=http://192.168.0.10:3000/api
```

## Testes

Para executar os testes:

```bash
flutter test
```

Para analisar o código:

```bash
flutter analyze
```

## Build

Para gerar o APK de produção:

```bash
flutter build apk
```

> Para produção, utilize HTTPS e remova `android:usesCleartextTraffic` do `android/app/src/main/AndroidManifest.xml`.

## Funcionalidades

O aplicativo permite:

- cadastro e login de pacientes;
- busca de fisioterapeutas;
- filtros por cidade, especialidade e modalidade;
- visualização do perfil do profissional;
- agendamento de consultas, com escolha de dia, horário, motivo e nível de dor;
- acompanhamento das consultas (próximas e histórico);
- cancelamento de consultas;
- edição do perfil pessoal.

> Contas de fisioterapeuta devem utilizar a versão web.

## Estrutura

```text
lib/
  core/        configuração da API, cliente HTTP, token, tema e utilitários
  models/      modelos de dados (espelham o backend)
  services/    serviços de acesso à API
  state/       sessão, navegação e injeção de dependências
  widgets/     componentes compartilhados
  screens/     telas (auth, home, physios, appointments, profile)
```
