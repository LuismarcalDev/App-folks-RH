import 'package:mysql_client/mysql_client.dart';

class ClienteModel {
  final int? id;
  final String nome;
  final String? cpfCnpj;
  final String? email;
  final String? telefone;
  final String? dataCriacao;

  ClienteModel({
    this.id,
    required this.nome,
    this.cpfCnpj,
    this.email,
    this.telefone,
    this.dataCriacao,
  });

  factory ClienteModel.fromRow(ResultSetRow row) {
    return ClienteModel(
      id: int.tryParse(row.colAt(0) ?? ''),
      nome: row.colAt(1) ?? '',
      cpfCnpj: row.colAt(2),
      email: row.colAt(3),
      telefone: row.colAt(5),
      dataCriacao: row.colAt(6),
    );
  }

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    if (json['nome'] == null || json['nome'].toString().trim().isEmpty) {
      throw ArgumentError('O nome do cliente é obrigatório.');
    }
    return ClienteModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      nome: json['nome'].toString().trim(),
      cpfCnpj: json['cpf_cnpj']?.toString().trim(),
      email: json['email']?.toString().trim(),
      telefone: json['telefone']?.toString().trim(),
      dataCriacao: json['data_criacao']?.toString().trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'cpf_cnpj': cpfCnpj,
      'email': email,
      'telefone': telefone,
      'data_criacao': dataCriacao,
    };
  }
}
