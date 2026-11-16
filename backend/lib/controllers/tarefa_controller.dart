import 'package:shelf/shelf.dart';
import '../services/tarefa_service.dart';
import '../services/usuario_service.dart';
import '../utils/api_response.dart';

class TarefaController {
  final TarefaService _tarefaService = TarefaService();
  final UsuarioService _usuarioService = UsuarioService();

  int? _actorId(Request request) =>
      int.tryParse(request.headers['x-user-id'] ?? '');

  Future<Response> listar(Request request) async {
    try {
      final userId = _actorId(request);
      if (userId != null) {
        final user = await _usuarioService.buscarPorId(userId);
        if (user != null && !user.permissoes.tarefas) {
          return ApiResponse.forbidden(
            'Acesso negado: você não tem permissão para acessar o módulo de Tarefas.',
          );
        }
      }

      final tarefas = await _tarefaService.listarTodas();
      return ApiResponse.ok({'tarefas': tarefas});
    } catch (e) {
      return ApiResponse.serverError('Erro ao listar tarefas: $e');
    }
  }

  Future<Response> criar(Request request) async {
    try {
      final data = await ApiResponse.readJsonBody(request);
      final actorId = _actorId(request) ??
          (data['userId'] is int
              ? data['userId'] as int
              : int.tryParse(data['userId']?.toString() ?? ''));

      String? autorNome;
      if (actorId != null) {
        final user = await _usuarioService.buscarPorId(actorId);
        if (user != null) {
          if (!user.permissoes.criarTarefas) {
            return ApiResponse.forbidden(
              'Acesso negado: apenas pessoas com permissão podem criar tarefas.',
            );
          }
          autorNome = user.nome;
        }
      }

      final nova = await _tarefaService.criar(data, autorNome: autorNome);
      return ApiResponse.created({
        'mensagem': 'Tarefa criada com sucesso!',
        'tarefa': nova,
      });
    } catch (e) {
      return ApiResponse.serverError('Erro ao criar tarefa: $e');
    }
  }

  Future<Response> atualizar(Request request, String id) async {
    try {
      final tarefaId = int.tryParse(id);
      if (tarefaId == null) {
        return ApiResponse.badRequest('ID de tarefa inválido.');
      }

      final actorId = _actorId(request);
      String? autorNome;
      if (actorId != null) {
        final user = await _usuarioService.buscarPorId(actorId);
        if (user != null) {
          if (!user.permissoes.editarTarefas) {
            return ApiResponse.forbidden(
              'Acesso negado: você não tem permissão para editar tarefas.',
            );
          }
          autorNome = user.nome;
        }
      }

      final data = await ApiResponse.readJsonBody(request);
      final atualizada = await _tarefaService.atualizar(
        tarefaId,
        data,
        autorNome: autorNome,
      );
      return ApiResponse.ok({
        'mensagem': 'Tarefa editada com sucesso!',
        'tarefa': atualizada,
      });
    } catch (e) {
      return ApiResponse.serverError('Erro ao editar tarefa: $e');
    }
  }

  Future<Response> atualizarStatus(Request request, String id) async {
    try {
      final tarefaId = int.tryParse(id);
      if (tarefaId == null) {
        return ApiResponse.badRequest('ID de tarefa inválido.');
      }

      final actorId = _actorId(request);
      String? autorNome;
      if (actorId != null) {
        final user = await _usuarioService.buscarPorId(actorId);
        if (user != null) {
          if (!user.permissoes.alterarStatus) {
            return ApiResponse.forbidden(
              'Acesso negado: você não tem permissão para alterar status.',
            );
          }
          autorNome = user.nome;
        }
      }

      final data = await ApiResponse.readJsonBody(request);
      final status = (data['status'] ?? 'em_andamento').toString();
      await _tarefaService.atualizarStatus(
        tarefaId,
        status,
        autorNome: autorNome,
      );
      return ApiResponse.ok({'mensagem': 'Status da tarefa alterado com sucesso!'});
    } catch (e) {
      return ApiResponse.serverError('Erro ao alterar status: $e');
    }
  }

  Future<Response> excluir(Request request, String id) async {
    try {
      final tarefaId = int.tryParse(id);
      if (tarefaId == null) {
        return ApiResponse.badRequest('ID de tarefa inválido.');
      }

      final actorId = _actorId(request);
      if (actorId != null) {
        final user = await _usuarioService.buscarPorId(actorId);
        if (user != null && !user.permissoes.excluirTarefas) {
          return ApiResponse.forbidden(
            'Acesso negado: você não tem permissão para excluir tarefas.',
          );
        }
      }

      await _tarefaService.excluir(tarefaId);
      return ApiResponse.ok({'mensagem': 'Tarefa excluída com sucesso!'});
    } catch (e) {
      return ApiResponse.serverError('Erro ao excluir tarefa: $e');
    }
  }

  Future<Response> listarLogs(Request request, String id) async {
    try {
      final tarefaId = int.tryParse(id);
      if (tarefaId == null) {
        return ApiResponse.badRequest('ID de tarefa inválido.');
      }
      final logs = await _tarefaService.listarLogs(tarefaId);
      return ApiResponse.ok({'logs': logs});
    } catch (e) {
      return ApiResponse.serverError('Erro ao buscar logs da tarefa: $e');
    }
  }
}
