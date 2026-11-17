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

  Future<Response> atualizar(Request request, String id) async {
    try {
      final negado = await _validarAcesso(request, 'editar');
      if (negado != null) return negado;

      final clienteId = int.tryParse(id);
      if (clienteId == null) {
        return ApiResponse.badRequest('ID de cliente inválido.');
      }

      final data = await ApiResponse.readJsonBody(request);
      final atualizado = await _clienteService.atualizar(clienteId, data);

      if (atualizado == null) {
        return ApiResponse.notFound('Cliente não encontrado.'); // AJUSTAR se não existir
      }

      return ApiResponse.ok({
        'mensagem': 'Cliente atualizado com sucesso!',
        'cliente': atualizado,
      });
    } on ArgumentError catch (e) {
      return ApiResponse.badRequest(e.message.toString());
    } catch (e) {
      return ApiResponse.serverError('Erro ao atualizar cliente: $e');
    }
  }

  Future<Response> excluir(Request request, String id) async {
    try {
      final negado = await _validarAcesso(request, 'excluir');
      if (negado != null) return negado;

      final clienteId = int.tryParse(id);
      if (clienteId == null) {
        return ApiResponse.badRequest('ID de cliente inválido.');
      }

      final removido = await _clienteService.excluir(clienteId);
      if (!removido) {
        return ApiResponse.notFound('Cliente não encontrado.'); // AJUSTAR se não existir
      }

      return ApiResponse.ok({'mensagem': 'Cliente excluído com sucesso!'});
    } on ArgumentError catch (e) {
      return ApiResponse.badRequest(e.message.toString());
    } catch (e) {
      final texto = e.toString().toLowerCase();
      if (texto.contains('foreign key')) {
        return ApiResponse.badRequest(
          'Não é possível excluir: o cliente possui registros vinculados.',
        );
      }
      return ApiResponse.serverError('Erro ao excluir cliente: $e');
    }
  }

  Future<Response?> _validarAcesso(Request request, String acao) async {
    final userId = int.tryParse(request.headers['x-user-id'] ?? '');
    if (userId == null) {
      return ApiResponse.forbidden('Acesso negado: usuário não identificado.');
    }

    final user = await _usuarioService.buscarPorId(userId);
    if (user == null || !user.permissoes.clientes) {
      return ApiResponse.forbidden(
        'Acesso negado: você não tem permissão para $acao clientes.',
      );
    }
    return null;
  }
}