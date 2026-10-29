import 'package:shelf_router/shelf_router.dart';
import '../controllers/funcionario_controller.dart';

class FuncionarioRoutes {
  final FuncionarioController _controller = FuncionarioController();

  Router get router {
    final router = Router();
    router.get('/', _controller.listar);
    router.put('/<id|[0-9]+>/permissoes', _controller.atualizarPermissoes);
    return router;
  }
}
