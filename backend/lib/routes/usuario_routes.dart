import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../models/usuario_model.dart';
import '../services/usuario_service.dart';
import '../utils/api_response.dart';

class UsuarioRoutes {
  final UsuarioService _service = UsuarioService();

  Future<Response> login(Request request) async {
    try {
      final bodyJson = await ApiResponse.readJsonBody(request);
      final email = (bodyJson['email'] ?? bodyJson['login'])?.toString().trim();
      final senha = bodyJson['senha']?.toString().trim();

      if (email == null || email.isEmpty || senha == null || senha.isEmpty) {
        return ApiResponse.badRequest('E-mail e senha são obrigatórios.');
      }

      final usuario = await _service.autenticar(email, senha);
      if (usuario == null) {
        return ApiResponse.unauthorized('E-mail ou senha incorretos.');
      }

      return ApiResponse.ok({
        'mensagem': 'Login realizado com sucesso!',
        'usuario': usuario.toJson(),
      });
    } catch (e) {
      return ApiResponse.serverError('Erro ao realizar login: $e');
    }
  }

  Router get router {
    final router = Router();

    router.get('/', (Request request) async {
      try {
        final usuarios = await _service.listarTodos();
        return ApiResponse.ok({
          'usuarios': usuarios.map((u) => u.toJson()).toList(),
        });
      } catch (e) {
        return ApiResponse.serverError('Erro ao listar usuários: $e');
      }
    });

    router.post('/', (Request request) async {
      try {
        final bodyJson = await ApiResponse.readJsonBody(request);
        if (bodyJson.isEmpty) {
          return ApiResponse.badRequest('O corpo da requisição não pode estar vazio.');
        }

        final usuarioModel = UsuarioModel.fromJson(bodyJson);
        final usuarioCadastrado = await _service.cadastrar(usuarioModel);

        return ApiResponse.created({
          'mensagem': 'Funcionário cadastrado com sucesso!',
          'usuario': usuarioCadastrado.toJson(),
        });
      } on ArgumentError catch (e) {
        return ApiResponse.badRequest(e.message.toString());
      } catch (e) {
        return ApiResponse.serverError('Erro ao cadastrar funcionário: $e');
      }
    });

    router.put('/<id|[0-9]+>/permissoes', (Request request, String id) async {
      try {
        final usuarioId = int.parse(id);
        final bodyJson = await ApiResponse.readJsonBody(request);
        if (bodyJson.isEmpty) {
          return ApiResponse.badRequest('O corpo da requisição não pode estar vazio.');
        }

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
          return ApiResponse.notFound('Usuário não encontrado.');
        }

        return ApiResponse.ok({
          'mensagem': 'Permissões salvas no banco MySQL com sucesso!',
          'usuario': atualizado.toJson(),
        });
      } catch (e) {
        return ApiResponse.serverError('Erro ao atualizar permissões: $e');
      }
    });

    return router;
  }
}
