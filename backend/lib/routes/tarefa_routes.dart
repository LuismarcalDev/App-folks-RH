import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/tarefa_service.dart';
import '../services/usuario_service.dart';

class TarefaRoutes {
  final TarefaService _service = TarefaService();
  final UsuarioService _usuarioService = UsuarioService();

  static const _jsonHeaders = {'content-type': 'application/json; charset=utf-8'};

  Router get router {
    final router = Router();

    router.get('/', (Request request) async {
      try {
        final tarefas = await _service.listarTodas();
        return Response.ok(
          jsonEncode({'tarefas': tarefas}),
          headers: _jsonHeaders,
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'erro': 'Erro ao listar tarefas: $e'}),
          headers: _jsonHeaders,
        );
      }
    });

    router.post('/', (Request request) async {
      try {
        final bodyString = await request.readAsString();
        final Map<String, dynamic> data = bodyString.isNotEmpty ? jsonDecode(bodyString) : {};

        final userId = data['userId'] is int
            ? data['userId'] as int
            : int.tryParse(data['userId']?.toString() ?? '');

        if (userId != null) {
          final user = await _usuarioService.buscarPorId(userId);
          if (user != null && !user.permissoes.criarTarefas) {
            return Response.forbidden(
              jsonEncode({'erro': 'Acesso negado: apenas pessoas com permissão podem criar tarefas.'}),
              headers: _jsonHeaders,
            );
          }
        }

        final nova = await _service.criar(data);
        return Response(
          201,
          body: jsonEncode({'mensagem': 'Tarefa criada com sucesso!', 'tarefa': nova}),
          headers: _jsonHeaders,
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'erro': 'Erro ao criar tarefa: $e'}),
          headers: _jsonHeaders,
        );
      }
    });

    router.put('/<id|[0-9]+>', (Request request, String id) async {
      try {
        final taskId = int.parse(id);
        final bodyString = await request.readAsString();
        final Map<String, dynamic> data = bodyString.isNotEmpty ? jsonDecode(bodyString) : {};

        final atualizada = await _service.atualizar(taskId, data);
        return Response.ok(
          jsonEncode({'mensagem': 'Tarefa editada com sucesso!', 'tarefa': atualizada}),
          headers: _jsonHeaders,
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'erro': 'Erro ao editar tarefa: $e'}),
          headers: _jsonHeaders,
        );
      }
    });

    router.put('/<id|[0-9]+>/status', (Request request, String id) async {
      try {
        final taskId = int.parse(id);
        final bodyString = await request.readAsString();
        final Map<String, dynamic> data = bodyString.isNotEmpty ? jsonDecode(bodyString) : {};
        final status = (data['status'] ?? 'em_andamento').toString();

        await _service.atualizarStatus(taskId, status);
        return Response.ok(
          jsonEncode({'mensagem': 'Status da tarefa alterado com sucesso!'}),
          headers: _jsonHeaders,
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'erro': 'Erro ao alterar status: $e'}),
          headers: _jsonHeaders,
        );
      }
    });

    router.delete('/<id|[0-9]+>', (Request request, String id) async {
      try {
        final taskId = int.parse(id);
        await _service.excluir(taskId);
        return Response.ok(
          jsonEncode({'mensagem': 'Tarefa excluída com sucesso!'}),
          headers: _jsonHeaders,
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'erro': 'Erro ao excluir tarefa: $e'}),
          headers: _jsonHeaders,
        );
      }
    });

    return router;
  }
}
