import '../config/database.dart';

class TarefaService {
  static String _formatDateToBr(String? dbDate) {
    if (dbDate == null || dbDate.isEmpty) return '25/08/2026';
    if (dbDate.contains('/')) return dbDate;
    final parts = dbDate.split(' ').first.split('-');
    if (parts.length == 3) {
      return '${parts[2].padLeft(2, '0')}/${parts[1].padLeft(2, '0')}/${parts[0]}';
    }
    return dbDate;
  }

  static String _formatDateToSql(String? brDate) {
    if (brDate == null || brDate.isEmpty) return '2026-08-25';
    if (brDate.contains('-')) return brDate.split(' ').first;
    final parts = brDate.split('/');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
    }
    return '2026-08-25';
  }

  static String _initialsFromName(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'L F';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0].toUpperCase()} ${parts[1][0].toUpperCase()}';
  }

  Future<List<Map<String, dynamic>>> listarTodas() async {
    final conn = await Database.getConnection();
    const sql = '''
      SELECT Id, Titulo, Descricao, Status, Prioridade, Data_Vencimento, Data_Criacao, Gestor_Nome, Visualizado
      FROM tarefas
      ORDER BY Id DESC;
    ''';
    final res = await conn.execute(sql);
    return res.rows.map((r) {
      final manager = r.colAt(7) ?? 'LUIS FELIPPE';
      return {
        'id': r.colAt(0) ?? '1',
        'title': r.colAt(1) ?? '',
        'description': r.colAt(2) ?? 'Sem descrição cadastrada.',
        'status': r.colAt(3) ?? 'em_andamento',
        'priority': r.colAt(4) ?? 'alta',
        'dueDate': _formatDateToBr(r.colAt(5)),
        'timeAgo': r.colAt(6) ?? 'Agora',
        'managerName': manager,
        'managerInitials': _initialsFromName(manager),
        'isViewed': (r.colAt(8) ?? '1') == '1',
      };
    }).toList();
  }

  Future<Map<String, dynamic>> criar(Map<String, dynamic> data) async {
    final conn = await Database.getConnection();
    final titulo = (data['title'] ?? '').toString().trim();
    final descricao = (data['description'] ?? 'Sem descrição cadastrada.').toString().trim();
    final status = (data['status'] ?? 'em_andamento').toString().trim();
    final prioridade = (data['priority'] ?? 'alta').toString().trim();
    final dataVencimento = _formatDateToSql(data['dueDate']?.toString());
    final gestorNome = (data['managerName'] ?? 'LUIS FELIPPE').toString().trim();
    final usuarioId = data['userId'] is int ? data['userId'] as int : int.tryParse(data['userId']?.toString() ?? '');

    const sql = '''
      INSERT INTO tarefas (Titulo, Usuarios_Id, Descricao, Status, Prioridade, Data_Vencimento, Data_Criacao, Gestor_Nome, Visualizado)
      VALUES (:titulo, :uid, :desc, :status, :prio, :venc, 'Agora', :gestor, 1);
    ''';

    final res = await conn.execute(sql, {
      'titulo': titulo,
      'uid': usuarioId,
      'desc': descricao,
      'status': status,
      'prio': prioridade,
      'venc': dataVencimento,
      'gestor': gestorNome,
    });

    final newId = res.lastInsertID.toInt();

    if (newId > 0) {
      try {
        await conn.execute(
          'INSERT INTO log_tarefa (Tarefas_Id, Acao, Descricao) VALUES (:tid, :acao, :desc);',
          {
            'tid': newId,
            'acao': 'criada',
            'desc': 'Tarefa criada por $gestorNome',
          },
        );
      } catch (_) {}
    }

    return {
      'id': newId.toString(),
      'title': titulo,
      'description': descricao,
      'status': status,
      'priority': prioridade,
      'dueDate': _formatDateToBr(dataVencimento),
      'timeAgo': 'Agora',
      'managerName': gestorNome,
      'managerInitials': _initialsFromName(gestorNome),
      'isViewed': true,
    };
  }

  Future<Map<String, dynamic>?> atualizar(int id, Map<String, dynamic> data) async {
    final conn = await Database.getConnection();
    final titulo = (data['title'] ?? '').toString().trim();
    final descricao = (data['description'] ?? 'Sem descrição cadastrada.').toString().trim();
    final status = (data['status'] ?? 'em_andamento').toString().trim();
    final prioridade = (data['priority'] ?? 'alta').toString().trim();
    final dataVencimento = _formatDateToSql(data['dueDate']?.toString());
    final gestorNome = (data['managerName'] ?? 'LUIS FELIPPE').toString().trim();

    const sql = '''
      UPDATE tarefas
      SET Titulo = :titulo,
          Descricao = :desc,
          Status = :status,
          Prioridade = :prio,
          Data_Vencimento = :venc,
          Gestor_Nome = :gestor
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
    });

    try {
      await conn.execute(
        'INSERT INTO log_tarefa (Tarefas_Id, Acao, Descricao) VALUES (:tid, :acao, :desc);',
        {
          'tid': id,
          'acao': status == 'concluida' ? 'concluida' : 'atualizada',
          'desc': 'Tarefa editada',
        },
      );
    } catch (_) {}

    return {
      'id': id.toString(),
      'title': titulo,
      'description': descricao,
      'status': status,
      'priority': prioridade,
      'dueDate': _formatDateToBr(dataVencimento),
      'timeAgo': data['timeAgo']?.toString() ?? 'Editado agora',
      'managerName': gestorNome,
      'managerInitials': _initialsFromName(gestorNome),
      'isViewed': true,
    };
  }

  Future<bool> atualizarStatus(int id, String status) async {
    final conn = await Database.getConnection();
    await conn.execute(
      'UPDATE tarefas SET Status = :status WHERE Id = :id;',
      {'id': id, 'status': status},
    );
    try {
      await conn.execute(
        'INSERT INTO log_tarefa (Tarefas_Id, Acao, Descricao) VALUES (:tid, :acao, :desc);',
        {
          'tid': id,
          'acao': status == 'concluida' ? 'concluida' : 'atualizada',
          'desc': 'Status alterado para $status',
        },
      );
    } catch (_) {}
    return true;
  }

  Future<bool> excluir(int id) async {
    final conn = await Database.getConnection();
    await conn.execute('DELETE FROM tarefas WHERE Id = :id;', {'id': id});
    return true;
  }
}
