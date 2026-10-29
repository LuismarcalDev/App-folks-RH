import 'package:shelf_router/shelf_router.dart';
import '../controllers/notificacao_controller.dart';

class NotificacaoRoutes {
  final NotificacaoController _controller = NotificacaoController();

  Router get router {
    final router = Router();
    router.get('/', _controller.listar);
    router.post('/', _controller.criar);
    return router;
  }
}
