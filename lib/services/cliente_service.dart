import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import 'api_service.dart';

class ClienteService {
  /// Lista todos os clientes cadastrados no MySQL
  static Future<List<Cliente>> listarClientes() async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiService.baseUrl}/api/clientes'),
            headers: {
              'Content-Type': 'application/json',
              if (UserSession.currentOrNull?.id != null)
                'x-user-id': UserSession.current.id.toString(),
            },
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final list = (data['clientes'] as List<dynamic>? ?? [])
            .map((e) => Cliente.fromJson(e as Map<String, dynamic>))
            .toList();
        return list;
      }
    } catch (_) {}
    return [];
  }

  /// Cadastra novo cliente no MySQL
  static Future<Cliente?> cadastrarCliente({
    required String nome,
    String? cpfCnpj,
    String? email,
    String? telefone,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/api/clientes'),
            headers: {
              'Content-Type': 'application/json',
              if (UserSession.currentOrNull?.id != null)
                'x-user-id': UserSession.current.id.toString(),
            },
            body: jsonEncode({
              'nome': nome.trim(),
              'cpf_cnpj': cpfCnpj?.trim(),
              'email': email?.trim(),
              'telefone': telefone?.trim(),
              'userId': UserSession.currentOrNull?.id,
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Cliente.fromJson(data['cliente'] as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }
}
