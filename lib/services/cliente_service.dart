import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user_profile.dart';
import 'api_service.dart';

class ClienteException implements Exception {
  final String message;
  final int? statusCode;

  const ClienteException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ClienteService {
  ClienteService._();

  static const Duration _timeout = Duration(seconds: 10);

  static Uri _uri([int? id]) {
    final base = '${ApiService.baseUrl}/api/clientes';
    return Uri.parse(id == null ? base : '$base/$id');
  }

  static Map<String, String> _headers() {
    final userId = UserSession.currentOrNull?.id;
    return {
      'Content-Type': 'application/json',
      if (userId != null) 'x-user-id': userId.toString(),
    };
  }

  static Map<String, dynamic> _corpo(Cliente cliente) {
    return {
      ...cliente.toJson(),
      'userId': UserSession.currentOrNull?.id,
    };
  }

  static Future<List<Cliente>> listarClientes() async {
    final resp = await _executar(() => http.get(_uri(), headers: _headers()));
    final data = _decodificar(resp);

    final lista = (data is Map ? data['clientes'] : null);
    if (lista is! List) return [];

    return lista
        .whereType<Map>()
        .map((e) => Cliente.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<Cliente?> cadastrarCliente(Cliente cliente) async {
    final resp = await _executar(
      () => http.post(
        _uri(),
        headers: _headers(),
        body: jsonEncode(_corpo(cliente)),
      ),
    );
    return _clienteDaResposta(resp);
  }

  static Future<Cliente?> atualizarCliente(Cliente cliente) async {
    final id = cliente.id;
    if (id == null) {
      throw const ClienteException('Cliente sem identificador para atualizar.');
    }
    final resp = await _executar(
      () => http.put(
        _uri(id),
        headers: _headers(),
        body: jsonEncode(_corpo(cliente)),
      ),
    );
    return _clienteDaResposta(resp);
  }

  static Future<void> excluirCliente(int id) async {
    await _executar(() => http.delete(_uri(id), headers: _headers()));
  }

  static Future<http.Response> _executar(
    Future<http.Response> Function() requisicao,
  ) async {
    try {
      final resp = await requisicao().timeout(_timeout);
      if (resp.statusCode >= 200 && resp.statusCode < 300) return resp;
      throw ClienteException(_mensagemDeErro(resp), statusCode: resp.statusCode);
    } on ClienteException {
      rethrow;
    } on TimeoutException {
      throw const ClienteException(
        'O servidor demorou para responder. Tente novamente.',
      );
    } catch (_) {
      throw const ClienteException(
        'Falha de conexão. Verifique sua internet e tente novamente.',
      );
    }
  }

  static dynamic _decodificar(http.Response resp) {
    if (resp.bodyBytes.isEmpty) return null;
    try {
      return jsonDecode(utf8.decode(resp.bodyBytes));
    } catch (_) {
      throw const ClienteException('Resposta inválida do servidor.');
    }
  }

  static Cliente? _clienteDaResposta(http.Response resp) {
    try {
      final data = _decodificar(resp);
      final c = (data is Map ? data['cliente'] : null);
      if (c is Map) return Cliente.fromJson(Map<String, dynamic>.from(c));
    } catch (_) {}
    return null;
  }

  static String _mensagemDeErro(http.Response resp) {
    try {
      final body = jsonDecode(utf8.decode(resp.bodyBytes));
      if (body is Map) {
        final msg = body['message'] ?? body['erro'] ?? body['error'];
        if (msg is String && msg.trim().isNotEmpty) return msg;
      }
    } catch (_) {
    }

    switch (resp.statusCode) {
      case 400:
      case 422:
        return 'Dados inválidos. Revise os campos.';
      case 401:
        return 'Sessão expirada. Faça login novamente.';
      case 403:
        return 'Você não tem permissão para esta ação.';
      case 404:
        return 'Cliente não encontrado.';
      case 409:
        return 'Já existe um cliente com esses dados.';
      default:
        return 'Erro no servidor (${resp.statusCode}).';
    }
  }
}