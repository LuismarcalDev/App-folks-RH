import 'dart:convert';
import 'package:shelf/shelf.dart';

class ApiResponse {
  static const Map<String, String> _headers = {
    'content-type': 'application/json; charset=utf-8',
  };

  static Future<Map<String, dynamic>> readJsonBody(Request request) async {
    final bodyString = await request.readAsString();
    if (bodyString.trim().isEmpty) return {};
    return jsonDecode(bodyString) as Map<String, dynamic>;
  }

  static Response ok(Map<String, dynamic> data) =>
      Response.ok(jsonEncode(data), headers: _headers);

  static Response created(Map<String, dynamic> data) =>
      Response(201, body: jsonEncode(data), headers: _headers);

  static Response badRequest(String message) =>
      Response.badRequest(body: jsonEncode({'erro': message}), headers: _headers);

  static Response unauthorized(String message) =>
      Response(401, body: jsonEncode({'erro': message}), headers: _headers);

  static Response forbidden(String message) =>
      Response.forbidden(jsonEncode({'erro': message}), headers: _headers);

  static Response notFound(String message) =>
      Response.notFound(jsonEncode({'erro': message}), headers: _headers);

  static Response serverError(String message) =>
      Response.internalServerError(body: jsonEncode({'erro': message}), headers: _headers);
}
