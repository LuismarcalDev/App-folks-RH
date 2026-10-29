import 'package:shelf/shelf.dart';
import '../models/usuario_model.dart';
import '../services/usuario_service.dart';
import '../utils/api_response.dart';

class FuncionarioController {
  final UsuarioService _usuarioService = UsuarioService();

  Future<Response> listar(Request request) async {
    try {
      final usuarios = await _usuarioService.listarTodos();
      return ApiResponse.ok({
        'funcionarios': usuarios.map((u) => u.toJson()).toList(),
        'usuarios': usuarios.map((u) => u.toJson()).toList(),
      });
    } catch (e) {
      return ApiResponse.serverError('Erro ao listar funcionários: $e');
    }
  }

  Future<Response> atualizarPermissoes(Request request, String id) async {
    try {
      final usuarioId = int.parse(id);
      final body = await ApiResponse.readJsonBody(request);
      if (body.isEmpty) {
        return ApiResponse.badRequest('O corpo da requisição não pode estar vazio.');
      }

      final novoTipo = body['tipo']?.toString().toLowerCase().trim();
      final permMap = body['permissoes'] is Map<String, dynamic>
          ? body['permissoes'] as Map<String, dynamic>
          : body;

      final permissoes = PermissoesUsuario.fromJson(
        permMap,
        fallbackTipo: novoTipo ?? 'assistente',
      );

      final atualizado = await _usuarioService.atualizarPermissoes(
        usuarioId,
        tipo: novoTipo,
        permissoes: permissoes,
      );

      if (atualizado == null) {
        return ApiResponse.notFound('Funcionário não encontrado.');
      }

      return ApiResponse.ok({
        'mensagem': 'Permissões atualizadas com sucesso!',
        'funcionario': atualizado.toJson(),
        'usuario': atualizado.toJson(),
      });
    } catch (e) {
      return ApiResponse.serverError('Erro ao atualizar permissões: $e');
    }
  }
}
