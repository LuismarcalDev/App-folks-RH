import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../models/usuario_model.dart';
import '../services/usuario_service.dart';

class UsuarioRoutes {
  final UsuarioService _service = UsuarioService();

  Router get router {
    final router = Router();

    router.post('/', (Request request) async {
      try {
        final bodyString = await request.readAsString();
        if (bodyString.isEmpty) {
          return Response.badRequest(
            body: jsonEncode({'erro': 'O corpo da requisição não pode estar vazio.'}),
            headers: {'content-type': 'application/json'},
          );
        }

        final Map<String, dynamic> bodyJson = jsonDecode(bodyString);
        final usuarioModel = UsuarioModel.fromJson(bodyJson);

        final usuarioCadastrado = await _service.cadastrar(usuarioModel);

        return Response(
          201,
          body: jsonEncode({
            'mensagem': 'Funcionário cadastrado com sucesso!',
            'usuario': usuarioCadastrado.toJson(),
          }),
          headers: {'content-type': 'application/json'},
        );
      } on ArgumentError catch (e) {
        return Response.badRequest(
          body: jsonEncode({'erro': e.message}),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'erro': 'Erro ao cadastrar funcionário: $e'}),
          headers: {'content-type': 'application/json'},
        );
      }
    });

    return router;
  }
}
