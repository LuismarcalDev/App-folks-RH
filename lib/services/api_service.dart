import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
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
          .timeout(const Duration(seconds: 3));

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

    if ((validAliases.contains(u) ||
            UserSession.allUsers.any((p) => p.email.toLowerCase() == u || p.name.toLowerCase() == u)) &&
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
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final list = (data['usuarios'] as List<dynamic>)
            .map((e) => UserProfile.fromBackendJson(e as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) {
          UserSession.allUsers = list;
          final currentIdx = list.indexWhere(
            (u) =>
                (UserSession.current.id != null && u.id == UserSession.current.id) ||
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
          .timeout(const Duration(seconds: 3));

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

  /// Cadastra novo usuário no banco MySQL `folks` com a função selecionada
  static Future<UserProfile?> cadastrarUsuario({
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
            Uri.parse('$baseUrl/usuarios'),
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
          .timeout(const Duration(seconds: 3));

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
    } catch (_) {
      // Fallback
    }

    final fallback = UserProfile(
      id: UserSession.allUsers.length + 1,
      name: nome.trim(),
      email: email.trim(),
      tipo: tipo,
      role: roleLabel,
      department: deptLabel,
      phone: '(11) 98765-4321',
      permissions: perms,
    );
    UserSession.setCurrent(fallback);
    return fallback;
  }

  /// Lista todas as funções cadastradas pelo Administrador no MySQL `folks`
  static Future<List<JobFunction>> listarFuncoes() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/funcoes'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final list = (data['funcoes'] as List<dynamic>)
            .map((e) => JobFunction.fromJson(e as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) {
          FunctionSession.functions = list;
          return list;
        }
      }
    } catch (_) {}
    return FunctionSession.functions;
  }

  /// Cadastra uma nova função (cargo) pelo Administrador no MySQL `folks`
  static Future<JobFunction> cadastrarFuncao({
    required String nome,
    required String tipo,
    required String departamento,
    required UserPermissions permissions,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/funcoes'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'nome': nome.trim(),
              'tipo': tipo,
              'departamento': departamento.trim(),
              'permissoes': permissions.toJson(),
            }),
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final created = JobFunction.fromJson(data['funcao'] as Map<String, dynamic>);
        FunctionSession.functions.add(created);
        return created;
      }
    } catch (_) {}

    final fallback = JobFunction(
      id: DateTime.now().millisecondsSinceEpoch,
      nome: nome.trim(),
      tipo: tipo,
      departamento: departamento.trim(),
      permissions: permissions,
    );
    FunctionSession.functions.add(fallback);
    return fallback;
  }

  /// Exclui uma função cadastrada pelo Administrador
  static Future<bool> excluirFuncao(int id) async {
    try {
      await http
          .delete(Uri.parse('$baseUrl/funcoes/$id'))
          .timeout(const Duration(seconds: 3));
    } catch (_) {}

    FunctionSession.functions.removeWhere((f) => f.id == id);
    return true;
  }

  /// Lista as tarefas do banco MySQL `folks` (ou retorna TaskSession em fallback)
  static Future<List<Task>> listarTarefas() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/tarefas'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final list = (data['tarefas'] as List<dynamic>)
            .map((e) => Task.fromJson(e as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) {
          TaskSession.tasks = list;
          return list;
        }
      }
    } catch (_) {}
    return TaskSession.tasks;
  }

  /// Cria uma nova tarefa somente se o usuário possuir permissão `criarTarefas`
  static Future<Task?> criarTarefa(Task newTask) async {
    if (!UserSession.current.permissions.criarTarefas) {
      return null;
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/tarefas'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(newTask.toJson(userId: UserSession.current.id)),
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final created = Task.fromJson(data['tarefa'] as Map<String, dynamic>);
        TaskSession.tasks.insert(0, created);
        return created;
      } else if (response.statusCode == 403) {
        return null;
      }
    } catch (_) {}

    TaskSession.tasks.insert(0, newTask);
    return newTask;
  }

  /// Edita/altera os dados completos de uma tarefa
  static Future<Task> editarTarefa(Task updatedTask) async {
    try {
      await http
          .put(
            Uri.parse('$baseUrl/tarefas/${updatedTask.id}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(updatedTask.toJson(userId: UserSession.current.id)),
          )
          .timeout(const Duration(seconds: 3));
    } catch (_) {}

    final idx = TaskSession.tasks.indexWhere((t) => t.id == updatedTask.id);
    if (idx != -1) {
      TaskSession.tasks[idx] = updatedTask;
    }
    return updatedTask;
  }

  /// Altera o status de uma tarefa
  static Future<Task> alterarStatusTarefa(Task task, TaskStatus newStatus) async {
    final updated = task.copyWith(status: newStatus);
    try {
      await http
          .put(
            Uri.parse('$baseUrl/tarefas/${task.id}/status'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'status': newStatus.backendKey}),
          )
          .timeout(const Duration(seconds: 3));
    } catch (_) {}

    final idx = TaskSession.tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      TaskSession.tasks[idx] = updated;
    }
    return updated;
  }

  /// Exclui uma tarefa
  static Future<bool> excluirTarefa(Task task) async {
    try {
      await http
          .delete(Uri.parse('$baseUrl/tarefas/${task.id}'))
          .timeout(const Duration(seconds: 3));
    } catch (_) {}

    TaskSession.tasks.removeWhere((t) => t.id == task.id);
    return true;
  }
}
