import 'package:shelf/shelf.dart';
import '../services/notificacao_service.dart';
import '../services/usuario_service.dart';
import '../utils/api_response.dart';

class NotificacaoController {
  final NotificacaoService _notificacaoService = NotificacaoService();
  final UsuarioService _usuarioService = UsuarioService();

  Future<Response> listar(Request request) async {
    try {
      final userIdHeader = request.headers['x-user-id'];
      int? userId;
      if (userIdHeader != null) {
        userId = int.tryParse(userIdHeader);
        if (userId != null) {
          final user = await _usuarioService.buscarPorId(userId);
          if (user != null && !user.permissoes.notificacoes) {
            return ApiResponse.forbidden(
              'Acesso negado: você não tem permissão para acessar o módulo de Notificações.',
            );
          }
        }
      }

      final notificacoes = await _notificacaoService.listarPorUsuario(userId);
      return ApiResponse.ok({'notificacoes': notificacoes});
    } catch (e) {
      return ApiResponse.serverError('Erro ao listar notificações: $e');
    }
  }

  Future<Response> criar(Request request) async {
    try {
      final data = await ApiResponse.readJsonBody(request);
      final criada = await _notificacaoService.criar(data);
      return ApiResponse.created({
        'mensagem': 'Notificação enviada com sucesso!',
        'notificacao': criada,
      });
    } on ArgumentError catch (e) {
      return ApiResponse.badRequest(e.message.toString());
    } catch (e) {
      return ApiResponse.serverError('Erro ao criar notificação: $e');
    }
  }
  
  int? _userId(Request request) =>
    int.tryParse(request.headers['x-user-id'] ?? '');

Future<Response> marcarLida(Request request, String id) async {
  try {
    final notifId = int.tryParse(id);
    if (notifId == null) return ApiResponse.badRequest('Id inválido.');
    final ok = await _notificacaoService.marcarComoLida(
        notifId, _userId(request));
    if (!ok) return ApiResponse.badRequest('Notificação não encontrada.');
    return ApiResponse.ok({'mensagem': 'Notificação marcada como lida.'});
  } catch (e) {
    return ApiResponse.serverError('Erro ao marcar notificação: $e');
  }
}

Future<Response> marcarTodasLidas(Request request) async {
  try {
    final total =
        await _notificacaoService.marcarTodasComoLidas(_userId(request));
    return ApiResponse.ok({'atualizadas': total});
  } catch (e) {
    return ApiResponse.serverError('Erro ao marcar notificações: $e');
  }
}

Future<Response> naoLidas(Request request) async {
  try {
    final total = await _notificacaoService.contarNaoLidas(_userId(request));
    return ApiResponse.ok({'nao_lidas': total});
  } catch (e) {
    return ApiResponse.serverError('Erro ao contar notificações: $e');
  }
}
}
