import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user_profile.dart';
import 'api_service.dart';

class NotificacaoService {
  /// Lista notificações do usuário no MySQL
  static Future<List<Notificacao>> listarNotificacoes() async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiService.baseUrl}/api/notificacoes'),
            headers: {
              'Content-Type': 'application/json',
              if (UserSession.currentOrNull?.id != null)
                'x-user-id': UserSession.current.id.toString(),
            },
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final list = (data['notificacoes'] as List<dynamic>? ?? [])
            .map((e) => Notificacao.fromJson(e as Map<String, dynamic>))
            .toList();
        return list;
      }
    } catch (_) {}
    return [];
  }

  /// Registra ou envia notificação no backend MySQL
  static Future<Notificacao?> enviarNotificacao({
    required String titulo,
    required String mensagem,
    int? usuarioId,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/api/notificacoes'),
            headers: {
              'Content-Type': 'application/json',
              if (UserSession.currentOrNull?.id != null)
                'x-user-id': UserSession.current.id.toString(),
            },
            body: jsonEncode({
              'titulo': titulo.trim(),
              'mensagem': mensagem.trim(),
              'usuario_id': ?usuarioId,
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final n = data['notificacao'] as Map<String, dynamic>?;
        if (n != null) return Notificacao.fromJson(n);
      }
    } catch (_) {}
    return null;
  }

  /// Marca uma notificação como lida
  static Future<bool> marcarComoLida(int id) async {
    try {
      final response = await http
          .put(
            Uri.parse('${ApiService.baseUrl}/api/notificacoes/$id/lida'),
            headers: {
              'Content-Type': 'application/json',
              if (UserSession.currentOrNull?.id != null)
                'x-user-id': UserSession.current.id.toString(),
            },
          )
          .timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Marca todas as notificações como lidas
  static Future<bool> marcarTodasComoLidas() async {
    try {
      final response = await http
          .put(
            Uri.parse('${ApiService.baseUrl}/api/notificacoes/lidas'),
            headers: {
              'Content-Type': 'application/json',
              if (UserSession.currentOrNull?.id != null)
                'x-user-id': UserSession.current.id.toString(),
            },
          )
          .timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
