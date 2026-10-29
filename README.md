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

## 2. Selecionar a branch

Depois de entrar na pasta do projeto, troque para a branch que será utilizada:

```bash
git checkout nome-da-branch
```

Substitua `nome-da-branch` pelo nome da branch que você irá utilizar.

Exemplo:

```bash
git checkout develop
```

Para verificar em qual branch você está:

```bash
git branch
```

A branch atual será identificada com `*`.

---

# 3. Configurar o banco de dados

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

# 4. Configurar o Backend

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

# 5. Abrir o projeto no VS Code

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

# 6. Instalar as dependências do Flutter

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

# 7. Iniciar o Backend

Abra um terminal dentro da pasta `backend`:

```bash
cd backend
```

Instale as dependências:

```bash
npm install
```

Depois inicie o backend:

```bash
npm start
```

O backend deverá ficar disponível na porta:

```text
8080
```

Não feche esse terminal enquanto estiver utilizando o aplicativo.

---

# 8. Executar pelo Google Chrome

Abra outro terminal na raiz do projeto:

```bash
cd App-folks-RH
```

Verifique se o Flutter reconheceu o Chrome:

```bash
flutter devices
```

O Chrome deverá aparecer na lista de dispositivos.

Para executar o aplicativo:

```bash
flutter run -d chrome
```

O Flutter irá compilar o projeto e abrir o aplicativo automaticamente no Google Chrome.

---

# 9. Executar utilizando Android Studio

Para utilizar um emulador Android:

### 1. Abra o Android Studio

Abra o Android Studio e acesse o **Device Manager**.

### 2. Inicie um emulador

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

# 10. Executar em um celular Android pelo cabo USB

Também é possível executar o aplicativo diretamente em um celular Android.

## 1. Ativar o modo desenvolvedor

No celular, acesse:

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

# 11. Comandos úteis

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

Sempre que for iniciar o projeto:

### 1. Clonar o projeto

```bash
git clone https://github.com/LuismarcalDev/App-folks-RH.git
```

### 2. Entrar na pasta

```bash
cd App-folks-RH
```

### 3. Selecionar a branch

```bash
git checkout nome-da-branch
```

### 4. Configurar o banco de dados

Execute o SQL disponível na raiz do projeto no MySQL.

### 5. Configurar o `.env`

Crie:

```text
backend/.env
```

E configure:

```env
DB_HOST=localhost
DB_PORT=3306
DB_NAME=folks
DB_USER=root
DB_PASSWORD=
PORT=8080
```

### 6. Instalar as dependências

Na raiz:

```bash
flutter pub get
```

No backend:

```bash
cd backend
npm install
```

### 7. Iniciar o backend

```bash
npm start
```

### 8. Executar o aplicativo

Chrome:

```bash
flutter run -d chrome
```

Android Studio:

```bash
flutter run
```

Celular USB:

```bash
flutter devices
flutter run -d ID_DO_DISPOSITIVO
```

O backend deve permanecer executando enquanto o aplicativo estiver sendo utilizado.
