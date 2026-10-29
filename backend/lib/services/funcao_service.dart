import '../config/database.dart';

class FuncaoService {
  bool _toBool(String? val, bool fallback) {
    if (val == null) return fallback;
    return val == '1' || val.toLowerCase() == 'true';
  }

  Future<List<Map<String, dynamic>>> listarTodas() async {
    final conn = await Database.getConnection();
    const sql = '''
      SELECT Id, Nome, Tipo, Departamento, Criar_Tarefas, Editar_Tarefas, Excluir_Tarefas, Alterar_Status, Ver_Desempenho, Gerenciar_Permissoes
      FROM funcoes
      ORDER BY Id ASC;
    ''';
    final res = await conn.execute(sql);
    return res.rows.map((r) {
      return {
        'id': int.tryParse(r.colAt(0) ?? '') ?? 1,
        'nome': r.colAt(1) ?? '',
        'tipo': r.colAt(2) ?? 'assistente',
        'departamento': r.colAt(3) ?? 'Folks RH - Recrutamento & Seleção',
        'permissoes': {
          'criar_tarefas': _toBool(r.colAt(4), false),
          'editar_tarefas': _toBool(r.colAt(5), true),
          'excluir_tarefas': _toBool(r.colAt(6), true),
          'alterar_status': _toBool(r.colAt(7), true),
          'ver_desempenho': _toBool(r.colAt(8), false),
          'gerenciar_permissoes': _toBool(r.colAt(9), false),
        },
      };
    }).toList();
  }

  Future<Map<String, dynamic>> criar(Map<String, dynamic> data) async {
    final conn = await Database.getConnection();
    final nome = (data['nome'] ?? '').toString().trim();
    final tipo = (data['tipo'] ?? 'assistente').toString().trim().toLowerCase();
    final departamento = (data['departamento'] ?? 'Folks RH - Recrutamento & Seleção').toString().trim();
    final perms = data['permissoes'] is Map<String, dynamic>
        ? data['permissoes'] as Map<String, dynamic>
        : <String, dynamic>{};

    bool parseB(dynamic v, bool def) {
      if (v == null) return def;
      if (v is bool) return v;
      if (v is int) return v != 0;
      return v.toString().toLowerCase() == 'true' || v.toString() == '1';
    }

    final criar = parseB(perms['criar_tarefas'], tipo == 'admin' || tipo == 'gestor' || tipo == 'analista');
    final editar = parseB(perms['editar_tarefas'], true);
    final excluir = parseB(perms['excluir_tarefas'], true);
    final status = parseB(perms['alterar_status'], true);
    final desempenho = parseB(perms['ver_desempenho'], tipo == 'admin' || tipo == 'gestor' || tipo == 'analista');
    final gerenciar = parseB(perms['gerenciar_permissoes'], tipo == 'admin');

    const sql = '''
      INSERT INTO funcoes (Nome, Tipo, Departamento, Criar_Tarefas, Editar_Tarefas, Excluir_Tarefas, Alterar_Status, Ver_Desempenho, Gerenciar_Permissoes)
      VALUES (:nome, :tipo, :depto, :criar, :editar, :excluir, :status, :desemp, :gerenc);
    ''';

    final res = await conn.execute(sql, {
      'nome': nome,
      'tipo': tipo,
      'depto': departamento,
      'criar': criar ? 1 : 0,
      'editar': editar ? 1 : 0,
      'excluir': excluir ? 1 : 0,
      'status': status ? 1 : 0,
      'desemp': desempenho ? 1 : 0,
      'gerenc': gerenciar ? 1 : 0,
    });

    final newId = res.lastInsertID.toInt();

    return {
      'id': newId,
      'nome': nome,
      'tipo': tipo,
      'departamento': departamento,
      'permissoes': {
        'criar_tarefas': criar,
        'editar_tarefas': editar,
        'excluir_tarefas': excluir,
        'alterar_status': status,
        'ver_desempenho': desempenho,
        'gerenciar_permissoes': gerenciar,
      },
    };
  }

  Future<bool> excluir(int id) async {
    final conn = await Database.getConnection();
    await conn.execute('DELETE FROM funcoes WHERE Id = :id;', {'id': id});
    return true;
  }
}
