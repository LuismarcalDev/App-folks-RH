class Notificacao {
  final int? id;
  final int? usuarioId;
  final String titulo;
  final String mensagem;
  final bool lida;
  final String? dataEnvio;

  const Notificacao({
    this.id,
    this.usuarioId,
    required this.titulo,
    required this.mensagem,
    this.lida = false,
    this.dataEnvio,
  });

  factory Notificacao.fromJson(Map<String, dynamic> json) {
    return Notificacao(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      usuarioId: json['usuario_id'] is int
          ? json['usuario_id'] as int
          : int.tryParse(json['usuario_id']?.toString() ?? ''),
      titulo: (json['titulo'] ?? '').toString(),
      mensagem: (json['mensagem'] ?? '').toString(),
      lida: json['lida'] == true || json['lida'] == 1,
      dataEnvio: json['data_envio']?.toString(),
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
