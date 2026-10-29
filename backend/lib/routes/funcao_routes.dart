import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/funcao_service.dart';

class FuncaoRoutes {
  final FuncaoService _service = FuncaoService();

  static const _jsonHeaders = {'content-type': 'application/json; charset=utf-8'};

  Router get router {
    final router = Router();

    router.get('/', (Request request) async {
      try {
        final funcoes = await _service.listarTodas();
        return Response.ok(
          jsonEncode({'funcoes': funcoes}),
          headers: _jsonHeaders,
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'erro': 'Erro ao listar funções: $e'}),
          headers: _jsonHeaders,
        );
      }
    });

    router.post('/', (Request request) async {
      try {
        final bodyString = await request.readAsString();
        final Map<String, dynamic> data = bodyString.isNotEmpty ? jsonDecode(bodyString) : {};
        final nome = (data['nome'] ?? '').toString().trim();
        if (nome.isEmpty) {
          return Response.badRequest(
            body: jsonEncode({'erro': 'O nome da função é obrigatório.'}),
            headers: _jsonHeaders,
          );
        }

        final criada = await _service.criar(data);
        return Response(
          201,
          body: jsonEncode({
            'mensagem': 'Função cadastrada com sucesso!',
            'funcao': criada,
          }),
          headers: _jsonHeaders,
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'erro': 'Erro ao cadastrar função: $e'}),
          headers: _jsonHeaders,
        );
      }
    });

    router.delete('/<id|[0-9]+>', (Request request, String id) async {
      try {
        final funcaoId = int.parse(id);
        await _service.excluir(funcaoId);
        return Response.ok(
          jsonEncode({'mensagem': 'Função excluída com sucesso!'}),
          headers: _jsonHeaders,
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'erro': 'Erro ao excluir função: $e'}),
          headers: _jsonHeaders,
        );
      }
    });

    return router;
  }
}
