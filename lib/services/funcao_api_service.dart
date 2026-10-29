import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import 'api_service.dart';

class FuncaoApiService {
  static Future<List<JobFunction>> listarFuncoes() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiService.baseUrl}/funcoes'))
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

  static Future<JobFunction> cadastrarFuncao({
    required String nome,
    required String tipo,
    required String departamento,
    required UserPermissions permissions,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/funcoes'),
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

  static Future<bool> excluirFuncao(int id) async {
    try {
      await http
          .delete(Uri.parse('${ApiService.baseUrl}/funcoes/$id'))
          .timeout(const Duration(seconds: 3));
    } catch (_) {}

    FunctionSession.functions.removeWhere((f) => f.id == id);
    return true;
  }
}
