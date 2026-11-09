class Notificacao {
  final int? id;
  final int? usuarioId;
  final String titulo;
  final String mensagem;
  final bool lida;
  final String? dataEnvio;
  final String tipo;

  const Notificacao({
    this.id,
    this.usuarioId,
    required this.titulo,
    required this.mensagem,
    this.lida = false,
    this.dataEnvio,
    this.tipo = 'geral',
  });

  factory Notificacao.fromJson(Map<String, dynamic> json) {
    return Notificacao(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? ''),
      usuarioId: json['usuario_id'] is int
          ? json['usuario_id'] as int
          : int.tryParse(json['usuario_id']?.toString() ?? ''),
      titulo: (json['titulo'] ?? '').toString(),
      mensagem: (json['mensagem'] ?? '').toString(),
      lida: json['lida'] == true || json['lida'] == 1,
      dataEnvio: json['data_envio']?.toString(),
      tipo: (json['tipo'] ?? 'geral').toString(),
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

  Notificacao copiarComoLida() => Notificacao(
    id: id,
    usuarioId: usuarioId,
    titulo: titulo,
    mensagem: mensagem,
    lida: true,
    dataEnvio: dataEnvio,
    tipo: tipo,
  );
}
