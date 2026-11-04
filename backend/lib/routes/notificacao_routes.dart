import 'package:shelf_router/shelf_router.dart';
import '../controllers/notificacao_controller.dart';

class NotificacaoRoutes {
  final NotificacaoController _controller = NotificacaoController();

  Router get router {
    final router = Router();
   router.get('/', _controller.listar);
   router.post('/', _controller.criar);
   router.get('/nao-lidas', _controller.naoLidas);
   router.put('/lidas', _controller.marcarTodasLidas);
   router.put('/<id>/lida', _controller.marcarLida);

    return router;
  }
}
