import '../config/database.dart';
import '../models/notificacao_model.dart';

class NotificacaoService {
  Future<List<Map<String, dynamic>>> listarPorUsuario(int? usuarioId) async {
    final conn = await Database.getConnection();
    String sql = '''
      SELECT Id, Usuario_Id, Titulo, Mensagem, Lida, Data_Envio
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
      INSERT INTO notificacoes (Usuario_Id, Titulo, Mensagem, Lida)
      VALUES (:uid, :titulo, :msg, 0);
    ''';

    final res = await conn.execute(sql, {
      'uid': model.usuarioId,
      'titulo': model.titulo,
      'msg': model.mensagem,
    });

    return NotificacaoModel(
      id: res.lastInsertID.toInt(),
      usuarioId: model.usuarioId,
      titulo: model.titulo,
      mensagem: model.mensagem,
      lida: false,
      dataEnvio: DateTime.now().toIso8601String(),
    ).toJson();
  }
}
