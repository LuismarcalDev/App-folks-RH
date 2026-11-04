import 'dart:io';
import 'package:dotenv/dotenv.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:backend_folks_rh/config/cors_middleware.dart';
import 'package:backend_folks_rh/config/database.dart';
import 'package:backend_folks_rh/controllers/auth_controller.dart';
import 'package:backend_folks_rh/routes/cliente_routes.dart';
import 'package:backend_folks_rh/routes/funcao_routes.dart';
import 'package:backend_folks_rh/routes/funcionario_routes.dart';
import 'package:backend_folks_rh/routes/notificacao_routes.dart';
import 'package:backend_folks_rh/routes/tarefa_routes.dart';
import 'package:backend_folks_rh/utils/api_response.dart';

void main() async {
  final env = DotEnv(includePlatformEnvironment: true)..load();
  final port = int.tryParse(env['PORT'] ?? '8081') ?? 8081;

  try {
    await Database.getConnection();
    print('✅ Banco de dados MySQL conectado com sucesso!');
  } catch (e) {
    print('⚠️ Não foi possível conectar ao MySQL na inicialização: $e');
  }

  final app = Router();

  final authController = AuthController();
  final funcionarioRoutes = FuncionarioRoutes();
  final clienteRoutes = ClienteRoutes();
  final tarefaRoutes = TarefaRoutes();
  final notificacaoRoutes = NotificacaoRoutes();
  final funcaoRoutes = FuncaoRoutes();

  // --- Rotas da API padronizadas ---
  app.post('/api/login', authController.login);
  app.post('/api/cadastro', authController.cadastro);
  app.mount('/api/funcionarios', funcionarioRoutes.router.call);
  app.mount('/api/clientes', clienteRoutes.router.call);
  app.mount('/api/tarefas', tarefaRoutes.router.call);
  app.mount('/api/notificacoes', notificacaoRoutes.router.call);
  app.mount('/api/funcoes', funcaoRoutes.router.call);

  // --- Compatibilidade direta ---
  app.post('/login', authController.login);
  app.post('/cadastro', authController.cadastro);
  app.mount('/funcionarios', funcionarioRoutes.router.call);
  app.mount('/usuarios', funcionarioRoutes.router.call);
  app.mount('/clientes', clienteRoutes.router.call);
  app.mount('/tarefas', tarefaRoutes.router.call);
  app.mount('/notificacoes', notificacaoRoutes.router.call);
  app.mount('/funcoes', funcaoRoutes.router.call);

  app.get('/health', (Request req) => ApiResponse.ok({'status': 'online', 'banco': 'mysql'}));

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsMiddleware())
      .addHandler(app.call);

  final server = await serve(handler, InternetAddress.anyIPv4, port);
  print('🚀 Servidor Folks RH rodando em: http://localhost:${server.port}');
}
