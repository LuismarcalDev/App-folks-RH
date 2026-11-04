import '../config/database.dart';
import '../models/notificacao_model.dart';

class NotificacaoService {
  Future<List<Map<String, dynamic>>> listarPorUsuario(int? usuarioId) async {
    final conn = await Database.getConnection();
    String sql = '''
      SELECT Id, Usuario_Id, Titulo, Mensagem, Lida, Data_Envio, Tipo
      FROM notificacoes
    ''';

    if (usuarioId != null) {
      sql += ' WHERE Usuario_Id = :uid OR Usuario_Id IS NULL ORDER BY Id DESC;';
      final res = await conn.execute(sql, {'uid': usuarioId});
      return res.rows.map((r) => NotificacaoModel.fromRow(r).toJson()).toList();
    } else {
      sql += ' ORDER BY Id DESC;';
      final res = await conn.execute(sql);
      return res.rows.map((r) => NotificacaoModel.fromRow(r).toJson()).toList();
    }
  }

  Future<Map<String, dynamic>> criar(Map<String, dynamic> data) async {
    final conn = await Database.getConnection();
    final model = NotificacaoModel.fromJson(data);

    const sql = '''
      INSERT INTO notificacoes (Usuario_Id, Titulo, Mensagem, Lida, Tipo)
  VALUES (:uid, :titulo, :msg, 0, :tipo);
    ''';

    final res = await conn.execute(sql, {
      'uid': model.usuarioId,
      'titulo': model.titulo,
      'msg': model.mensagem,
      'tipo': model.tipo,
    });

    return NotificacaoModel(
      id: res.lastInsertID.toInt(),
      usuarioId: model.usuarioId,
      titulo: model.titulo,
      mensagem: model.mensagem,
      lida: false,
      dataEnvio: DateTime.now().toIso8601String(),
      tipo: model.tipo,
    ).toJson();
  }

  Future<bool> marcarComoLida(int id, int? usuarioId) async {
    final conn = await Database.getConnection();
    final res = await conn.execute(
      'UPDATE notificacoes SET Lida = 1 '
      'WHERE Id = :id AND (Usuario_Id = :uid OR Usuario_Id IS NULL)',
      {'id': id, 'uid': usuarioId},
    );
    return res.affectedRows.toInt() > 0;
  }

  Future<int> marcarTodasComoLidas(int? usuarioId) async {
    final conn = await Database.getConnection();
    final res = await conn.execute(
      'UPDATE notificacoes SET Lida = 1 '
      'WHERE Lida = 0 AND (Usuario_Id = :uid OR Usuario_Id IS NULL)',
      {'uid': usuarioId},
    );
    return res.affectedRows.toInt();
  }

  Future<int> contarNaoLidas(int? usuarioId) async {
    final conn = await Database.getConnection();
    final res = await conn.execute(
      'SELECT COUNT(*) FROM notificacoes '
      'WHERE Lida = 0 AND (Usuario_Id = :uid OR Usuario_Id IS NULL)',
      {'uid': usuarioId},
    );
    return int.tryParse(res.rows.first.colAt(0) ?? '0') ?? 0;
  }

  /// Gera uma notificação automática a partir de um evento de tarefa.
  Future<Map<String, dynamic>?> gerarParaTarefa({
    required String tipo,
    required int? usuarioId,
    required String tituloTarefa,
    String? novoStatus,
    String? autor,
  }) async {
    try {
      late final String titulo;
      late final String mensagem;

      switch (tipo) {
        case 'tarefa_atribuida':
          titulo = 'Nova Tarefa Atribuída';
          mensagem = autor != null && autor.trim().isNotEmpty
              ? '$autor atribuiu "$tituloTarefa" a você.'
              : 'A tarefa "$tituloTarefa" foi atribuída a você.';
          break;
        case 'status_alterado':
          titulo = 'Status Alterado';
          mensagem = novoStatus != null && novoStatus.trim().isNotEmpty
              ? 'A tarefa "$tituloTarefa" mudou para $novoStatus.'
              : 'O status da tarefa "$tituloTarefa" foi alterado.';
          break;
        default:
          return null;
      }

      return await criar({
        'usuario_id': usuarioId,
        'titulo': titulo,
        'mensagem': mensagem,
        'tipo': tipo,
      });
    } catch (_) {
      return null;
    }
  }
}
