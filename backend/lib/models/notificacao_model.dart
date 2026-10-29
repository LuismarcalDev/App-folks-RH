import 'package:mysql_client/mysql_client.dart';

class NotificacaoModel {
  final int? id;
  final int? usuarioId;
  final String titulo;
  final String mensagem;
  final bool lida;
  final String? dataEnvio;

  NotificacaoModel({
    this.id,
    this.usuarioId,
    required this.titulo,
    required this.mensagem,
    this.lida = false,
    this.dataEnvio,
  });

  factory NotificacaoModel.fromRow(ResultSetRow row) {
    return NotificacaoModel(
      id: int.tryParse(row.colAt(0) ?? ''),
      usuarioId: int.tryParse(row.colAt(1) ?? ''),
      titulo: row.colAt(2) ?? '',
      mensagem: row.colAt(3) ?? '',
      lida: (row.colAt(4) ?? '0') == '1',
      dataEnvio: row.colAt(5),
    );
  }

  factory NotificacaoModel.fromJson(Map<String, dynamic> json) {
    if (json['titulo'] == null || json['titulo'].toString().trim().isEmpty) {
      throw ArgumentError('O título da notificação é obrigatório.');
    }
    if (json['mensagem'] == null || json['mensagem'].toString().trim().isEmpty) {
      throw ArgumentError('A mensagem da notificação é obrigatória.');
    }
    return NotificacaoModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      usuarioId: json['usuario_id'] is int
          ? json['usuario_id'] as int
          : int.tryParse(json['usuario_id']?.toString() ?? ''),
      titulo: json['titulo'].toString().trim(),
      mensagem: json['mensagem'].toString().trim(),
      lida: json['lida'] == true || json['lida'] == 1,
      dataEnvio: json['data_envio']?.toString().trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'titulo': titulo,
      'mensagem': mensagem,
      'lida': lida,
      'data_envio': dataEnvio,
    };
  }
}
