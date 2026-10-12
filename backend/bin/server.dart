import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:dotenv/dotenv.dart';

import '../lib/config/database.dart';
import '../lib/routes/usuario_routes.dart';

void main() async {
  final env = DotEnv(includePlatformEnvironment: true)..load();
  final port = int.tryParse(env['PORT'] ?? '8080') ?? 8080;

  try {
    await Database.getConnection();
  } catch (e) {
    print('⚠️ Não foi possível conectar ao MySQL na inicialização. Verifique o seu .env e o MySQL Workbench.');
  }

  final app = Router();

  app.mount('/usuarios', UsuarioRoutes().router.call);

  app.get('/health', (Request req) {
    return Response.ok(
      '{"status": "online", "banco": "mysql"}',
      headers: {'content-type': 'application/json'},
    );
  });

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(app.call);

  final server = await serve(handler, InternetAddress.anyIPv4, port);
  print('🚀 Servidor Folks RH rodando em: http://localhost:${server.port}');
}

