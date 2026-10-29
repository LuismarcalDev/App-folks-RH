import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import 'api_service.dart';

class AuthService {
  /// Realiza login autenticando diretamente no Backend MySQL
  static Future<UserProfile?> login(String login, String senha) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/api/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'login': login.trim(),
              'senha': senha.trim(),
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final userMap = data['usuario'] as Map<String, dynamic>;
        final profile = UserProfile.fromBackendJson(userMap);
        UserSession.setCurrent(profile);
        return profile;
      }
    } catch (e) {
      // Falha na requisição de rede ou backend indisponível
    }
    return null;
  }

  /// Cadastra novo usuário/funcionário diretamente no Backend MySQL
  static Future<UserProfile?> cadastrar({
    required String nome,
    required String email,
    required String senha,
    String tipo = 'assistente',
    String? funcaoNome,
    String? departamento,
    String? codigoUtilizado,
    UserPermissions? permissions,
  }) async {
    final perms = permissions ?? UserPermissions.forTipo(tipo);
    final roleLabel = (funcaoNome != null && funcaoNome.trim().isNotEmpty)
        ? funcaoNome.trim()
        : UserProfile.roleLabelForTipo(tipo);
    final deptLabel = (departamento != null && departamento.trim().isNotEmpty)
        ? departamento.trim()
        : UserProfile.departmentForTipo(tipo);

    try {
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/api/cadastro'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'nome': nome.trim(),
              'email': email.trim(),
              'senha': senha.trim(),
              'tipo': tipo,
              'funcao_nome': roleLabel,
              'codigo_utilizado': codigoUtilizado,
              'permissoes': perms.toJson(),
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final userMap = data['usuario'] as Map<String, dynamic>;
        final created = UserProfile.fromBackendJson(userMap).copyWith(
          role: roleLabel,
          department: deptLabel,
        );
        UserSession.setCurrent(created);
        return created;
      }
    } catch (e) {
      // Erro ao cadastrar
    }
    return null;
  }
}
