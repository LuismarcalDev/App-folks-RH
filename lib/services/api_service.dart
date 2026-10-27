import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8081';

  /// Realiza login consultando o banco MySQL `folks` via backend
  static Future<UserProfile?> login(String login, String senha) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
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
      } else if (response.statusCode == 401) {
        return null;
      }
    } catch (_) {
      // Fallback para lista em memória caso o servidor local esteja desligado
    }

    final u = login.trim().toLowerCase();
    const validAliases = {
      'luis',
      'luis@folksrh.com',
      'luis@folksrh.com.br',
      'adm',
      'adm@folksrh.com.br',
      'igor',
      'igor@folksrh.com',
      'igor@folksrh.com.br',
      'gestor',
      'alessandra',
      'alessandra@folksrh.com',
      'alessandra@folksrh.com.br',
      'assistente',
    };

    if ((validAliases.contains(u) || UserSession.allUsers.any((p) => p.email.toLowerCase() == u || p.name.toLowerCase() == u)) &&
        senha.trim() == '1234') {
      UserSession.login(u);
      return UserSession.current;
    }
    return null;
  }

  /// Lista todos os usuários e suas permissões salvos no MySQL `folks`
  static Future<List<UserProfile>> listarUsuarios() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/usuarios'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final list = (data['usuarios'] as List<dynamic>)
            .map((e) => UserProfile.fromBackendJson(e as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) {
          UserSession.allUsers = list;
          final currentIdx = list.indexWhere(
            (u) => (UserSession.current.id != null && u.id == UserSession.current.id) ||
                u.email.toLowerCase() == UserSession.current.email.toLowerCase(),
          );
          if (currentIdx != -1) {
            UserSession.current = list[currentIdx];
          }
          return list;
        }
      }
    } catch (_) {
      // Retorna cache em memória se offline
    }
    return UserSession.allUsers;
  }

  /// Atualiza o nível (tipo) e as permissões de um usuário no banco MySQL `folks`
  static Future<UserProfile?> salvarPermissoes({
    required int userId,
    required String tipo,
    required UserPermissions permissions,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/usuarios/$userId/permissoes'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'tipo': tipo,
              'permissoes': permissions.toJson(),
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final userMap = data['usuario'] as Map<String, dynamic>;
        final updated = UserProfile.fromBackendJson(userMap);

        final idx = UserSession.allUsers.indexWhere((u) => u.id == userId);
        if (idx != -1) {
          UserSession.allUsers[idx] = updated;
        }
        if (UserSession.current.id == userId) {
          UserSession.current = updated;
        }
        return updated;
      }
    } catch (_) {
      // Atualiza localmente em fallback
    }

    final idx = UserSession.allUsers.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      final updated = UserSession.allUsers[idx].copyWith(
        tipo: tipo,
        role: UserProfile.roleLabelForTipo(tipo),
        department: UserProfile.departmentForTipo(tipo),
        avatarChoice: permissions.gerenciarPermissoes ? AvatarChoice.admin : AvatarChoice.person,
        permissions: permissions,
      );
      UserSession.allUsers[idx] = updated;
      if (UserSession.current.id == userId) {
        UserSession.current = updated;
      }
      return updated;
    }
    return null;
  }

  /// Cadastra novo usuário no banco MySQL `folks`
  static Future<UserProfile?> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
    String tipo = 'assistente',
    String? codigoUtilizado,
    UserPermissions? permissions,
  }) async {
    final perms = permissions ?? UserPermissions.forTipo(tipo);
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/usuarios'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'nome': nome.trim(),
              'email': email.trim(),
              'senha': senha.trim(),
              'tipo': tipo,
              'codigo_utilizado': codigoUtilizado,
              'permissoes': perms.toJson(),
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final userMap = data['usuario'] as Map<String, dynamic>;
        final created = UserProfile.fromBackendJson(userMap);
        UserSession.setCurrent(created);
        return created;
      }
    } catch (_) {
      // Fallback
    }

    final fallback = UserProfile(
      id: UserSession.allUsers.length + 1,
      name: nome.trim(),
      email: email.trim(),
      tipo: tipo,
      role: UserProfile.roleLabelForTipo(tipo),
      department: UserProfile.departmentForTipo(tipo),
      phone: '(11) 98765-4321',
      permissions: perms,
    );
    UserSession.setCurrent(fallback);
    return fallback;
  }
}
