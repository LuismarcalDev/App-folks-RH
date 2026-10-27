import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:dotenv/dotenv.dart';

import '../lib/config/database.dart';
import '../lib/routes/funcao_routes.dart';
import '../lib/routes/tarefa_routes.dart';
import '../lib/routes/usuario_routes.dart';

Middleware _corsMiddleware() {
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization',
  };

  return (Handler innerHandler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: corsHeaders);
      }
      final response = await innerHandler(request);
      return response.change(headers: corsHeaders);
    };
  };
}

void main() async {
  final env = DotEnv(includePlatformEnvironment: true)..load();
  final port = int.tryParse(env['PORT'] ?? '8081') ?? 8081;

  try {
    await Database.getConnection();
  } catch (e) {
    print('⚠️ Não foi possível conectar ao MySQL na inicialização. Verifique o seu .env e o MySQL Workbench.');
  }

  final app = Router();
  final usuarioRoutes = UsuarioRoutes();
  final tarefaRoutes = TarefaRoutes();
  final funcaoRoutes = FuncaoRoutes();

  app.mount('/usuarios', usuarioRoutes.router.call);
  app.mount('/tarefas', tarefaRoutes.router.call);
  app.mount('/funcoes', funcaoRoutes.router.call);
  app.post('/login', usuarioRoutes.login);

  app.get('/health', (Request req) {
    return Response.ok(
      '{"status": "online", "banco": "mysql"}',
      headers: {'content-type': 'application/json'},
    );
  });

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_corsMiddleware())
      .addHandler(app.call);

  final server = await serve(handler, InternetAddress.anyIPv4, port);
  print('🚀 Servidor Folks RH rodando em: http://localhost:${server.port}');
}
