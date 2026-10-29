# App Folks RH

Aplicativo desenvolvido em Flutter com backend em Node.js e banco de dados MySQL.

## Requisitos

Antes de iniciar, tenha instalado:

- Flutter
- Dart
- Android Studio
- Google Chrome
- VS Code
- MySQL

### Extensões do VS Code

Instale as seguintes extensões:

- Flutter
- Dart
- Flutter Widget Snippets

### Dispositivo para execução

O projeto pode ser executado utilizando:

- Google Chrome
- Emulador do Android Studio
- Celular Android conectado via cabo USB

---

# Instalação

## 1. Clonar o projeto

Crie uma pasta na Área de Trabalho para armazenar o projeto.

Abra o terminal dentro dessa pasta e execute:

```bash
git clone https://github.com/LuismarcalDev/App-folks-RH.git
```

Depois entre na pasta do projeto:

```bash
cd App-folks-RH
```

---

# 2. Configurar o banco de dados

Abra o MySQL utilizando o MySQL Workbench ou outro cliente MySQL.

Na raiz do projeto existe o arquivo com o código necessário para criação do banco de dados.

Localize o arquivo de banco de dados dentro da pasta:

```text
App-folks-RH/
```

Copie o código SQL desse arquivo e execute no MySQL.

Depois da execução, confirme se o banco de dados foi criado corretamente.

O banco utilizado pelo projeto é:

```text
folks
```

---

# 3. Configurar o Backend

Dentro do projeto existe a pasta:

```text
backend/
```

Crie dentro dela um arquivo chamado:

```text
.env
```

Adicione o seguinte conteúdo:

```env
DB_HOST=localhost
DB_PORT=3306
DB_NAME=folks
DB_USER=root
DB_PASSWORD=
PORT=8080
```

Informe a senha do seu MySQL na variável:

```env
DB_PASSWORD=
```

Por exemplo:

```env
DB_PASSWORD=123456
```

Se o seu MySQL não possuir senha, deixe:

```env
DB_PASSWORD=
```

---

# 4. Abrir o projeto no VS Code

Abra a pasta:

```text
App-folks-RH
```

no VS Code.

A estrutura principal deverá ser semelhante a:

```text
App-folks-RH/
├── backend/
├── lib/
├── android/
├── web/
├── pubspec.yaml
└── ...
```

---

# 5. Instalar as dependências do Flutter

Abra o terminal na raiz do projeto:

```bash
cd App-folks-RH
```

Execute:

```bash
flutter pub get
```

Esse comando instala as dependências utilizadas pelo projeto.

---

# 6. Iniciar o Backend

Antes de executar o aplicativo, o backend precisa estar funcionando.

Abra um terminal dentro da pasta `backend`:

```bash
cd backend
```

Instale as dependências:

```bash
npm install
```

Depois inicie o backend utilizando o comando definido no projeto.

Caso o projeto utilize o script `start`:

```bash
npm start
```

O backend deverá ficar disponível na porta:

```text
8080
```

Não feche esse terminal enquanto estiver utilizando o aplicativo.

---

# 7. Executar pelo Google Chrome

Abra outro terminal na raiz do projeto:

```bash
cd App-folks-RH
```

Verifique se o Flutter reconheceu o Chrome:

```bash
flutter devices
```

Deverá aparecer algo semelhante a:

```text
Chrome • chrome • web-javascript • Google Chrome
```

Para executar o aplicativo no Chrome:

```bash
flutter run -d chrome
```

O Flutter irá compilar o projeto e abrir o aplicativo automaticamente no Google Chrome.

Também é possível utilizar:

```bash
flutter run
```

Nesse caso, o Flutter poderá solicitar ou utilizar um dispositivo disponível.

---

# 8. Executar utilizando Android Studio

Para utilizar um emulador Android:

### 1. Abra o Android Studio

Abra o Android Studio e acesse o **Device Manager**.

### 2. Crie ou inicie um dispositivo virtual

Escolha um dispositivo Android e inicie o emulador.

### 3. Verifique o dispositivo

Na raiz do projeto, execute:

```bash
flutter devices
```

O emulador deverá aparecer na lista.

### 4. Execute o projeto

```bash
flutter run
```

Ou especifique o dispositivo:

```bash
flutter run -d ID_DO_DISPOSITIVO
```

Exemplo:

```bash
flutter run -d emulator-5554
```

---

# 9. Executar em um celular Android pelo cabo USB

Também é possível executar o aplicativo diretamente em um celular Android.

## 1. Ativar o modo desenvolvedor

No celular:

```text
Configurações
→ Sobre o telefone
→ Número da versão
```

Toque várias vezes em **Número da versão** até ativar as opções do desenvolvedor.

Depois acesse:

```text
Configurações
→ Opções do desenvolvedor
```

Ative:

```text
Depuração USB
```

---

## 2. Conectar o celular

Conecte o celular ao computador utilizando um cabo USB.

Quando aparecer a mensagem:

```text
Permitir depuração USB?
```

aceite a solicitação.

---

## 3. Verificar se o Flutter reconheceu o celular

Na raiz do projeto execute:

```bash
flutter devices
```

O celular deverá aparecer na lista.

Exemplo:

```text
M2006C3LII • XXXXXXXX • android-arm64 • Android 10
```

---

## 4. Executar o aplicativo

Execute:

```bash
flutter run
```

Ou informe diretamente o dispositivo:

```bash
flutter run -d ID_DO_DISPOSITIVO
```

Exemplo:

```bash
flutter run -d XXXXXXXX
```

O Flutter irá compilar e instalar o aplicativo no celular.

---

# 10. Comandos úteis

### Verificar instalação do Flutter

```bash
flutter doctor
```

### Verificar dispositivos disponíveis

```bash
flutter devices
```

### Instalar dependências

```bash
flutter pub get
```

### Executar no Chrome

```bash
flutter run -d chrome
```

### Executar no Android

```bash
flutter run
```

### Limpar arquivos de compilação

```bash
flutter clean
```

Depois:

```bash
flutter pub get
```

---

# Ordem recomendada para executar o projeto

Sempre que for iniciar o projeto do zero:

### Terminal 1 — Backend

```bash
cd App-folks-RH/backend
npm install
npm start
```

### Terminal 2 — Flutter

```bash
cd App-folks-RH
flutter pub get
```

Depois escolha onde executar:

### Chrome

```bash
flutter run -d chrome
```

### Android Studio / Emulador

```bash
flutter run
```

### Celular USB

```bash
flutter devices
flutter run -d ID_DO_CELULAR
```

O backend deve permanecer executando enquanto o aplicativo estiver sendo utilizado.
