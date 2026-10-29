import 'package:shelf/shelf.dart';
import '../models/usuario_model.dart';
import '../services/usuario_service.dart';
import '../utils/api_response.dart';

class AuthController {
  final UsuarioService _usuarioService = UsuarioService();

  Future<Response> login(Request request) async {
    try {
      final body = await ApiResponse.readJsonBody(request);
      final email = (body['email'] ?? body['login'])?.toString().trim();
      final senha = body['senha']?.toString().trim();

      if (email == null || email.isEmpty || senha == null || senha.isEmpty) {
        return ApiResponse.badRequest('E-mail e senha são obrigatórios.');
      }

      final usuario = await _usuarioService.autenticar(email, senha);
      if (usuario == null) {
        return ApiResponse.unauthorized('E-mail ou senha incorretos.');
      }

      return ApiResponse.ok({
        'mensagem': 'Login realizado com sucesso!',
        'usuario': usuario.toJson(),
      });
    } catch (e) {
      return ApiResponse.serverError('Erro ao autenticar: $e');
    }
  }

  Future<Response> cadastro(Request request) async {
    try {
      final body = await ApiResponse.readJsonBody(request);
      if (body.isEmpty) {
        return ApiResponse.badRequest('O corpo da requisição não pode estar vazio.');
      }

      final usuarioModel = UsuarioModel.fromJson(body);
      final usuarioCadastrado = await _usuarioService.cadastrar(usuarioModel);

      return ApiResponse.created({
        'mensagem': 'Funcionário cadastrado com sucesso!',
        'usuario': usuarioCadastrado.toJson(),
      });
    } on ArgumentError catch (e) {
      return ApiResponse.badRequest(e.message.toString());
    } catch (e) {
      return ApiResponse.serverError('Erro ao cadastrar funcionário: $e');
    }
  }
}
