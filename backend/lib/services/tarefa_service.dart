import '../config/database.dart';
import '../models/tarefa_model.dart';

class TarefaService {
  Future<List<Map<String, dynamic>>> listarTodas() async {
    final conn = await Database.getConnection();
    const sql = '''
      SELECT t.Id, t.Titulo, t.Descricao, t.Status, t.Prioridade, t.Data_Vencimento, t.Data_Criacao, 
             t.Gestor_Nome, t.Visualizado, t.Usuarios_Id, t.Clientes_Id,
             c.Nome AS Cliente_Nome, u.Nome AS Usuario_Nome
      FROM tarefas t
      LEFT JOIN clientes c ON c.Id = t.Clientes_Id
      LEFT JOIN usuarios u ON u.Id = t.Usuarios_Id
      ORDER BY t.Id DESC;
    ''';
    final res = await conn.execute(sql);
    return res.rows.map((r) => TarefaModel.fromRow(r).toJson()).toList();
  }

  Future<Map<String, dynamic>> criar(Map<String, dynamic> data) async {
    final conn = await Database.getConnection();
    final titulo = (data['title'] ?? '').toString().trim();
    final descricao = (data['description'] ?? 'Sem descrição cadastrada.').toString().trim();
    final status = (data['status'] ?? 'em_andamento').toString().trim();
    final prioridade = (data['priority'] ?? 'alta').toString().trim();
    final dataVencimento = TarefaModel.formatDateToSql(data['dueDate']?.toString());
    final gestorNome = (data['managerName'] ?? 'LUIS FELIPPE').toString().trim();
    final usuarioId = data['userId'] is int
        ? data['userId'] as int
        : int.tryParse(data['userId']?.toString() ?? '');
    final clienteId = data['clientId'] is int
        ? data['clientId'] as int
        : int.tryParse(data['clientId']?.toString() ?? '');
    final clientName = data['clientName']?.toString().trim();

    const sql = '''
      INSERT INTO tarefas (Titulo, Usuarios_Id, Clientes_Id, Descricao, Status, Prioridade, Data_Vencimento, Data_Criacao, Gestor_Nome, Visualizado)
      VALUES (:titulo, :uid, :cid, :desc, :status, :prio, :venc, 'Agora', :gestor, 1);
    ''';

    final res = await conn.execute(sql, {
      'titulo': titulo,
      'uid': usuarioId,
      'cid': clienteId,
      'desc': descricao,
      'status': status,
      'prio': prioridade,
      'venc': dataVencimento,
      'gestor': gestorNome,
    });

    final newId = res.lastInsertID.toInt();
    if (newId > 0) {
      await _registrarLog(newId, 'criada', 'Tarefa criada por $gestorNome');
    }

    return TarefaModel(
      id: newId.toString(),
      title: titulo,
      description: descricao,
      status: status,
      priority: prioridade,
      dueDate: TarefaModel.formatDateToBr(dataVencimento),
      timeAgo: 'Agora',
      managerName: gestorNome,
      managerInitials: TarefaModel.initialsFromName(gestorNome),
      isViewed: true,
      userId: usuarioId,
      clientId: clienteId,
      clientName: clientName,
    ).toJson();
  }

  Future<Map<String, dynamic>> atualizar(int id, Map<String, dynamic> data) async {
    final conn = await Database.getConnection();
    final titulo = (data['title'] ?? '').toString().trim();
    final descricao = (data['description'] ?? 'Sem descrição cadastrada.').toString().trim();
    final status = (data['status'] ?? 'em_andamento').toString().trim();
    final prioridade = (data['priority'] ?? 'alta').toString().trim();
    final dataVencimento = TarefaModel.formatDateToSql(data['dueDate']?.toString());
    final gestorNome = (data['managerName'] ?? 'LUIS FELIPPE').toString().trim();
    final usuarioId = data['userId'] is int
        ? data['userId'] as int
        : int.tryParse(data['userId']?.toString() ?? '');
    final clienteId = data['clientId'] is int
        ? data['clientId'] as int
        : int.tryParse(data['clientId']?.toString() ?? '');
    final clientName = data['clientName']?.toString().trim();

    const sql = '''
      UPDATE tarefas
      SET Titulo = :titulo,
          Descricao = :desc,
          Status = :status,
          Prioridade = :prio,
          Data_Vencimento = :venc,
          Gestor_Nome = :gestor,
          Usuarios_Id = :uid,
          Clientes_Id = :cid
      WHERE Id = :id;
    ''';

    await conn.execute(sql, {
      'id': id,
      'titulo': titulo,
      'desc': descricao,
      'status': status,
      'prio': prioridade,
      'venc': dataVencimento,
      'gestor': gestorNome,
      'uid': usuarioId,
      'cid': clienteId,
    });

    await _registrarLog(
      id,
      status == 'concluida' ? 'concluida' : 'atualizada',
      'Tarefa editada',
    );

    return TarefaModel(
      id: id.toString(),
      title: titulo,
      description: descricao,
      status: status,
      priority: prioridade,
      dueDate: TarefaModel.formatDateToBr(dataVencimento),
      timeAgo: data['timeAgo']?.toString() ?? 'Editado agora',
      managerName: gestorNome,
      managerInitials: TarefaModel.initialsFromName(gestorNome),
      isViewed: true,
      userId: usuarioId,
      clientId: clienteId,
      clientName: clientName,
    ).toJson();
  }

  Future<bool> atualizarStatus(int id, String status) async {
    final conn = await Database.getConnection();
    await conn.execute(
      'UPDATE tarefas SET Status = :status WHERE Id = :id;',
      {'id': id, 'status': status},
    );
    await _registrarLog(
      id,
      status == 'concluida' ? 'concluida' : 'atualizada',
      'Status alterado para $status',
    );
    return true;
  }

  Future<bool> excluir(int id) async {
    final conn = await Database.getConnection();
    await conn.execute('DELETE FROM tarefas WHERE Id = :id;', {'id': id});
    return true;
  }

  Future<void> _registrarLog(int tarefaId, String acao, String descricao) async {
    try {
      final conn = await Database.getConnection();
      await conn.execute(
        'INSERT INTO log_tarefa (Tarefas_Id, Acao, Descricao) VALUES (:tid, :acao, :desc);',
        {'tid': tarefaId, 'acao': acao, 'desc': descricao},
      );
    } catch (_) {}
  }
}
