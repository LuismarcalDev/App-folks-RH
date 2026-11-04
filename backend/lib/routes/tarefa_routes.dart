import 'package:shelf_router/shelf_router.dart';
import '../controllers/tarefa_controller.dart';

class TarefaRoutes {
  final TarefaController _controller = TarefaController();

  Router get router {
    final router = Router();
    router.get('/', _controller.listar);
    router.post('/', _controller.criar);
    router.put('/<id|[0-9]+>', _controller.atualizar);
    router.put('/<id|[0-9]+>/status', _controller.atualizarStatus);
    router.delete('/<id|[0-9]+>', _controller.excluir);
    router.get('/<id|[0-9]+>/logs', _controller.listarLogs);
    return router;
  }
}
