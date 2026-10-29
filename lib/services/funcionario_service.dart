import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import 'api_service.dart';

class FuncionarioService {
  /// Lista todos os funcionários e permissões do MySQL
  static Future<List<UserProfile>> listarFuncionarios() async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiService.baseUrl}/api/funcionarios'),
            headers: {
              'Content-Type': 'application/json',
              if (UserSession.currentOrNull?.id != null)
                'x-user-id': UserSession.current.id.toString(),
            },
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rawList = (data['funcionarios'] ?? data['usuarios']) as List<dynamic>? ?? [];
        final list = rawList
            .map((e) => UserProfile.fromBackendJson(e as Map<String, dynamic>))
            .toList();

        if (list.isNotEmpty) {
          UserSession.allUsers = list;
          final currentId = UserSession.currentOrNull?.id;
          if (currentId != null) {
            final match = list.where((u) => u.id == currentId);
            if (match.isNotEmpty) {
              UserSession.setCurrent(match.first);
            }
          }
          return list;
        }
      }
    } catch (_) {}
    return UserSession.allUsers;
  }

  /// Salva cargo e permissões de um funcionário no MySQL
  static Future<UserProfile?> salvarPermissoes({
    required int funcionarioId,
    required String tipo,
    required UserPermissions permissions,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('${ApiService.baseUrl}/api/funcionarios/$funcionarioId/permissoes'),
            headers: {
              'Content-Type': 'application/json',
              if (UserSession.currentOrNull?.id != null)
                'x-user-id': UserSession.current.id.toString(),
            },
            body: jsonEncode({
              'tipo': tipo,
              'permissoes': permissions.toJson(),
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final userMap = (data['funcionario'] ?? data['usuario']) as Map<String, dynamic>;
        final updated = UserProfile.fromBackendJson(userMap);

        final idx = UserSession.allUsers.indexWhere((u) => u.id == funcionarioId);
        if (idx != -1) {
          UserSession.allUsers[idx] = updated;
        }
        if (UserSession.currentOrNull?.id == funcionarioId) {
          UserSession.setCurrent(updated);
        }
        return updated;
      }
    } catch (_) {}
    return null;
  }
}
