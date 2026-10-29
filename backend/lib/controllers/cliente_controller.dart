import 'package:shelf/shelf.dart';
import '../services/cliente_service.dart';
import '../services/usuario_service.dart';
import '../utils/api_response.dart';

class ClienteController {
  final ClienteService _clienteService = ClienteService();
  final UsuarioService _usuarioService = UsuarioService();

  Future<Response> listar(Request request) async {
    try {
      final userIdHeader = request.headers['x-user-id'];
      if (userIdHeader != null) {
        final userId = int.tryParse(userIdHeader);
        if (userId != null) {
          final user = await _usuarioService.buscarPorId(userId);
          if (user != null && !user.permissoes.clientes) {
            return ApiResponse.forbidden(
              'Acesso negado: você não tem permissão para acessar o módulo de Clientes.',
            );
          }
        }
      }

      final clientes = await _clienteService.listarTodos();
      return ApiResponse.ok({'clientes': clientes});
    } catch (e) {
      return ApiResponse.serverError('Erro ao listar clientes: $e');
    }
  }

  Future<Response> cadastrar(Request request) async {
    try {
      final data = await ApiResponse.readJsonBody(request);
      final userId = data['userId'] is int
          ? data['userId'] as int
          : int.tryParse(data['userId']?.toString() ?? request.headers['x-user-id'] ?? '');

      if (userId != null) {
        final user = await _usuarioService.buscarPorId(userId);
        if (user != null && !user.permissoes.clientes) {
          return ApiResponse.forbidden(
            'Acesso negado: você não tem permissão para cadastrar clientes.',
          );
        }
      }

      final criado = await _clienteService.cadastrar(data);
      return ApiResponse.created({
        'mensagem': 'Cliente cadastrado com sucesso!',
        'cliente': criado,
      });
    } on ArgumentError catch (e) {
      return ApiResponse.badRequest(e.message.toString());
    } catch (e) {
      return ApiResponse.serverError('Erro ao cadastrar cliente: $e');
    }
  }
}
