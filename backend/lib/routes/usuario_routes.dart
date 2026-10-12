import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../models/usuario_model.dart';
import '../services/usuario_service.dart';

class UsuarioRoutes {
  final UsuarioService _service = UsuarioService();

  Future<Response> login(Request request) async {
    try {
      final bodyString = await request.readAsString();
      if (bodyString.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'erro': 'O corpo da requisição não pode estar vazio.'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final Map<String, dynamic> bodyJson = jsonDecode(bodyString);
      final email = (bodyJson['email'] ?? bodyJson['login'])?.toString().trim();
      final senha = bodyJson['senha']?.toString().trim();

      if (email == null || email.isEmpty || senha == null || senha.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'erro': 'E-mail e senha são obrigatórios.'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final usuario = await _service.autenticar(email, senha);

      if (usuario == null) {
        return Response(
          401,
          body: jsonEncode({'erro': 'E-mail ou senha incorretos.'}),
          headers: {'content-type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'mensagem': 'Login realizado com sucesso!',
          'usuario': usuario.toJson(),
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'erro': 'Erro ao realizar login: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  Router get router {
    final router = Router();

    router.post('/', (Request request) async {
      try {
        final bodyString = await request.readAsString();
        if (bodyString.isEmpty) {
          return Response.badRequest(
            body: jsonEncode({'erro': 'O corpo da requisição não pode estar vazio.'}),
            headers: {'content-type': 'application/json'},
          );
        }

        final Map<String, dynamic> bodyJson = jsonDecode(bodyString);
        final usuarioModel = UsuarioModel.fromJson(bodyJson);

        final usuarioCadastrado = await _service.cadastrar(usuarioModel);

        return Response(
          201,
          body: jsonEncode({
            'mensagem': 'Funcionário cadastrado com sucesso!',
            'usuario': usuarioCadastrado.toJson(),
          }),
          headers: {'content-type': 'application/json'},
        );
      } on ArgumentError catch (e) {
        return Response.badRequest(
          body: jsonEncode({'erro': e.message}),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'erro': 'Erro ao cadastrar funcionário: $e'}),
          headers: {'content-type': 'application/json'},
        );
      }
    });

    router.post('/login', login);

    return router;
  }
}
