import '../config/database.dart';
import '../models/tarefa_model.dart';
import 'notificacao_service.dart';

class TarefaService {
  final NotificacaoService _notificacaoService = NotificacaoService();

  static String _statusLabel(String status) {
    switch (status.toLowerCase().trim()) {
      case 'em_andamento':
        return 'Em Andamento';
      case 'pendente':
        return 'Pendente';
      case 'concluida':
      case 'concluido':
        return 'Concluída';
      case 'cancelada':
        return 'Cancelada';
      default:
        return status;
    }
  }

  Future<Map<String, dynamic>?> _buscarResumo(int id) async {
    final conn = await Database.getConnection();
    final res = await conn.execute(
      'SELECT Titulo, Status, Usuarios_Id FROM tarefas WHERE Id = :id LIMIT 1;',
      {'id': id},
    );
    if (res.rows.isEmpty) return null;
    final row = res.rows.first;
    return {
      'titulo': row.colByName('Titulo') ?? 'Tarefa #$id',
      'status': row.colByName('Status') ?? 'em_andamento',
      'usuarioId': int.tryParse(row.colByName('Usuarios_Id') ?? ''),
    };
  }
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

  Future<Map<String, dynamic>> criar(
    Map<String, dynamic> data, {
    String? autorNome,
  }) async {
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
    final autor = (autorNome != null && autorNome.trim().isNotEmpty)
        ? autorNome.trim()
        : gestorNome;
    if (newId > 0) {
      await _registrarLog(newId, 'criada', 'Tarefa criada por $autor');
      if (usuarioId != null) {
        await _notificacaoService.gerarParaTarefa(
          tipo: 'tarefa_atribuida',
          usuarioId: usuarioId,
          tituloTarefa: titulo,
          autor: autor,
        );
      }
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

  Future<Map<String, dynamic>> atualizar(
    int id,
    Map<String, dynamic> data, {
    String? autorNome,
  }) async {
    final conn = await Database.getConnection();
    final anterior = await _buscarResumo(id);
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

    final autor = (autorNome != null && autorNome.trim().isNotEmpty)
        ? autorNome.trim()
        : gestorNome;

    await _registrarLog(
      id,
      status == 'concluida' ? 'concluida' : 'atualizada',
      autorNome != null ? 'Tarefa editada por $autor' : 'Tarefa editada',
    );

    final previousUserId = anterior?['usuarioId'] as int?;
    final previousStatus = anterior?['status'] as String?;

    if (usuarioId != null && usuarioId != previousUserId) {
      await _notificacaoService.gerarParaTarefa(
        tipo: 'tarefa_atribuida',
        usuarioId: usuarioId,
        tituloTarefa: titulo,
        autor: autor,
      );
    }

    final targetUserId = usuarioId ?? previousUserId;
    if (previousStatus != null && status != previousStatus && targetUserId != null) {
      await _notificacaoService.gerarParaTarefa(
        tipo: 'status_alterado',
        usuarioId: targetUserId,
        tituloTarefa: titulo,
        novoStatus: _statusLabel(status),
      );
    }

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

  Future<bool> atualizarStatus(
    int id,
    String status, {
    String? autorNome,
  }) async {
    final conn = await Database.getConnection();
    final anterior = await _buscarResumo(id);

    await conn.execute(
      'UPDATE tarefas SET Status = :status WHERE Id = :id;',
      {'id': id, 'status': status},
    );

    final statusLabel = _statusLabel(status);
    final acao = status == 'concluida'
        ? 'concluida'
        : status == 'cancelada'
            ? 'cancelada'
            : 'atualizada';
    await _registrarLog(
      id,
      acao,
      autorNome != null
          ? 'Status alterado para $statusLabel por $autorNome'
          : 'Status alterado para $statusLabel',
    );

    final previousUserId = anterior?['usuarioId'] as int?;
    final previousStatus = anterior?['status'] as String?;
    final tituloTarefa = (anterior?['titulo'] as String?) ?? 'Tarefa #$id';

    if (previousStatus != status && previousUserId != null) {
      await _notificacaoService.gerarParaTarefa(
        tipo: 'status_alterado',
        usuarioId: previousUserId,
        tituloTarefa: tituloTarefa,
        novoStatus: statusLabel,
      );
    }

    return true;
  }

  Future<bool> excluir(int id) async {
    final conn = await Database.getConnection();
    await conn.execute('DELETE FROM tarefas WHERE Id = :id;', {'id': id});
    return true;
  }

  Future<List<Map<String, dynamic>>> listarLogs(int tarefaId) async {
    final conn = await Database.getConnection();
    const sql = '''
      SELECT Id, Tarefas_Id, Acao, Descricao, Data_Criacao
      FROM log_tarefa
      WHERE Tarefas_Id = :tid
      ORDER BY Data_Criacao DESC, Id DESC;
    ''';
    final res = await conn.execute(sql, {'tid': tarefaId});
    return res.rows.map((r) {
      final row = r.assoc();
      return {
        'id': row['Id'] != null ? int.tryParse(row['Id']!) : null,
        'tarefasId': row['Tarefas_Id'] != null ? int.tryParse(row['Tarefas_Id']!) : null,
        'acao': row['Acao'],
        'descricao': row['Descricao'],
        'dataCriacao': row['Data_Criacao'],
      };
    }).toList();
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
