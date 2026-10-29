import 'package:shelf_router/shelf_router.dart';
import '../controllers/cliente_controller.dart';

class ClienteRoutes {
  final ClienteController _controller = ClienteController();

  Router get router {
    final router = Router();
    router.get('/', _controller.listar);
    router.post('/', _controller.cadastrar);
    return router;
  }
}
