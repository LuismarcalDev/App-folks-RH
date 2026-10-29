import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import 'api_service.dart';

class TarefaService {
  static Future<List<Task>> listarTarefas() async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiService.baseUrl}/api/tarefas'),
            headers: {
              'Content-Type': 'application/json',
              if (UserSession.currentOrNull?.id != null)
                'x-user-id': UserSession.current.id.toString(),
            },
          )
          .timeout(const Duration(seconds: 4));

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

  static Future<Task?> criarTarefa(Task newTask) async {
    if (!UserSession.current.permissions.criarTarefas) {
      return null;
    }

    try {
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/api/tarefas'),
            headers: {
              'Content-Type': 'application/json',
              if (UserSession.currentOrNull?.id != null)
                'x-user-id': UserSession.current.id.toString(),
            },
            body: jsonEncode(newTask.toJson(userId: UserSession.currentOrNull?.id)),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final created = Task.fromJson(data['tarefa'] as Map<String, dynamic>);
        TaskSession.tasks.insert(0, created);
        return created;
      }
    } catch (_) {}

    TaskSession.tasks.insert(0, newTask);
    return newTask;
  }

  static Future<Task> editarTarefa(Task updatedTask) async {
    try {
      await http
          .put(
            Uri.parse('${ApiService.baseUrl}/api/tarefas/${updatedTask.id}'),
            headers: {
              'Content-Type': 'application/json',
              if (UserSession.currentOrNull?.id != null)
                'x-user-id': UserSession.current.id.toString(),
            },
            body: jsonEncode(updatedTask.toJson(userId: UserSession.currentOrNull?.id)),
          )
          .timeout(const Duration(seconds: 4));
    } catch (_) {}

    final idx = TaskSession.tasks.indexWhere((t) => t.id == updatedTask.id);
    if (idx != -1) {
      TaskSession.tasks[idx] = updatedTask;
    }
    return updatedTask;
  }

  static Future<Task> alterarStatusTarefa(Task task, TaskStatus newStatus) async {
    final updated = task.copyWith(status: newStatus);
    try {
      await http
          .put(
            Uri.parse('${ApiService.baseUrl}/api/tarefas/${task.id}/status'),
            headers: {
              'Content-Type': 'application/json',
              if (UserSession.currentOrNull?.id != null)
                'x-user-id': UserSession.current.id.toString(),
            },
            body: jsonEncode({'status': newStatus.backendKey}),
          )
          .timeout(const Duration(seconds: 4));
    } catch (_) {}

    final idx = TaskSession.tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      TaskSession.tasks[idx] = updated;
    }
    return updated;
  }

  static Future<bool> excluirTarefa(Task task) async {
    try {
      await http
          .delete(
            Uri.parse('${ApiService.baseUrl}/api/tarefas/${task.id}'),
            headers: {
              if (UserSession.currentOrNull?.id != null)
                'x-user-id': UserSession.current.id.toString(),
            },
          )
          .timeout(const Duration(seconds: 4));
    } catch (_) {}

    TaskSession.tasks.removeWhere((t) => t.id == task.id);
    return true;
  }
}
