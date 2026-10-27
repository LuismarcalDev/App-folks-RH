import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../models/usuario_model.dart';
import '../services/usuario_service.dart';

class UsuarioRoutes {
  final UsuarioService _service = UsuarioService();

  static const _jsonHeaders = {'content-type': 'application/json; charset=utf-8'};

  Future<Response> login(Request request) async {
    try {
      final bodyString = await request.readAsString();
      if (bodyString.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'erro': 'O corpo da requisição não pode estar vazio.'}),
          headers: _jsonHeaders,
        );
      }

      final Map<String, dynamic> bodyJson = jsonDecode(bodyString);
      final email = (bodyJson['email'] ?? bodyJson['login'])?.toString().trim();
      final senha = bodyJson['senha']?.toString().trim();

      if (email == null || email.isEmpty || senha == null || senha.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'erro': 'E-mail e senha são obrigatórios.'}),
          headers: _jsonHeaders,
        );
      }

      final usuario = await _service.autenticar(email, senha);

      if (usuario == null) {
        return Response(
          401,
          body: jsonEncode({'erro': 'E-mail ou senha incorretos.'}),
          headers: _jsonHeaders,
        );
      }

      return Response.ok(
        jsonEncode({
          'mensagem': 'Login realizado com sucesso!',
          'usuario': usuario.toJson(),
        }),
        headers: _jsonHeaders,
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'erro': 'Erro ao realizar login: $e'}),
        headers: _jsonHeaders,
      );
    }
  }

  Router get router {
    final router = Router();

    router.get('/', (Request request) async {
      try {
        final usuarios = await _service.listarTodos();
        return Response.ok(
          jsonEncode({
            'usuarios': usuarios.map((u) => u.toJson()).toList(),
          }),
          headers: _jsonHeaders,
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'erro': 'Erro ao listar usuários: $e'}),
          headers: _jsonHeaders,
        );
      }
    });

    router.post('/', (Request request) async {
      try {
        final bodyString = await request.readAsString();
        if (bodyString.isEmpty) {
          return Response.badRequest(
            body: jsonEncode({'erro': 'O corpo da requisição não pode estar vazio.'}),
            headers: _jsonHeaders,
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
          headers: _jsonHeaders,
        );
      } on ArgumentError catch (e) {
        return Response.badRequest(
          body: jsonEncode({'erro': e.message}),
          headers: _jsonHeaders,
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'erro': 'Erro ao cadastrar funcionário: $e'}),
          headers: _jsonHeaders,
        );
      }
    });

    router.put('/<id|[0-9]+>/permissoes', (Request request, String id) async {
      try {
        final usuarioId = int.parse(id);
        final bodyString = await request.readAsString();
        if (bodyString.isEmpty) {
          return Response.badRequest(
            body: jsonEncode({'erro': 'O corpo da requisição não pode estar vazio.'}),
            headers: _jsonHeaders,
          );
        }

        final Map<String, dynamic> bodyJson = jsonDecode(bodyString);
        final novoTipo = bodyJson['tipo']?.toString().toLowerCase().trim();
        final permMap = bodyJson['permissoes'] is Map<String, dynamic>
            ? bodyJson['permissoes'] as Map<String, dynamic>
            : bodyJson;

        final permissoes = PermissoesUsuario.fromJson(
          permMap,
          fallbackTipo: novoTipo ?? 'assistente',
        );

        final atualizado = await _service.atualizarPermissoes(
          usuarioId,
          tipo: novoTipo,
          permissoes: permissoes,
        );

        if (atualizado == null) {
          return Response.notFound(
            jsonEncode({'erro': 'Usuário não encontrado.'}),
            headers: _jsonHeaders,
          );
        }

        return Response.ok(
          jsonEncode({
            'mensagem': 'Permissões salvas no banco MySQL com sucesso!',
            'usuario': atualizado.toJson(),
          }),
          headers: _jsonHeaders,
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'erro': 'Erro ao atualizar permissões: $e'}),
          headers: _jsonHeaders,
        );
      }
    });

    router.post('/login', login);

    return router;
  }
}
