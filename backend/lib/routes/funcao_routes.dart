import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/funcao_service.dart';
import '../utils/api_response.dart';

class FuncaoRoutes {
  final FuncaoService _service = FuncaoService();

  Router get router {
    final router = Router();

    router.get('/', (Request request) async {
      try {
        final funcoes = await _service.listarTodas();
        return ApiResponse.ok({'funcoes': funcoes});
      } catch (e) {
        return ApiResponse.serverError('Erro ao listar funções: $e');
      }
    });

    router.post('/', (Request request) async {
      try {
        final data = await ApiResponse.readJsonBody(request);
        final nome = (data['nome'] ?? '').toString().trim();
        if (nome.isEmpty) {
          return ApiResponse.badRequest('O nome da função é obrigatório.');
        }

        final criada = await _service.criar(data);
        return ApiResponse.created({
          'mensagem': 'Função cadastrada com sucesso!',
          'funcao': criada,
        });
      } catch (e) {
        return ApiResponse.serverError('Erro ao cadastrar função: $e');
      }
    });

    router.delete('/<id|[0-9]+>', (Request request, String id) async {
      try {
        await _service.excluir(int.parse(id));
        return ApiResponse.ok({'mensagem': 'Função excluída com sucesso!'});
      } catch (e) {
        return ApiResponse.serverError('Erro ao excluir função: $e');
      }
    });

    return router;
  }
}
