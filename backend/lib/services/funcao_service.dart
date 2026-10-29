import '../config/database.dart';
import '../models/funcao_model.dart';
import '../models/permissao_model.dart';

class FuncaoService {
  Future<List<Map<String, dynamic>>> listarTodas() async {
    final conn = await Database.getConnection();
    const sql = '''
      SELECT Id, Nome, Tipo, Departamento, Criar_Tarefas, Editar_Tarefas, Excluir_Tarefas, Alterar_Status, Ver_Desempenho, Gerenciar_Permissoes
      FROM funcoes
      ORDER BY Id ASC;
    ''';
    final res = await conn.execute(sql);
    return res.rows.map((r) => FuncaoModel.fromRow(r).toJson()).toList();
  }

  Future<Map<String, dynamic>> criar(Map<String, dynamic> data) async {
    final conn = await Database.getConnection();
    final nome = (data['nome'] ?? '').toString().trim();
    final tipo = (data['tipo'] ?? 'assistente').toString().trim().toLowerCase();
    final departamento = (data['departamento'] ?? 'Folks RH - Recrutamento & Seleção').toString().trim();
    final permMap = data['permissoes'] is Map<String, dynamic>
        ? data['permissoes'] as Map<String, dynamic>
        : <String, dynamic>{};

    final perms = PermissoesUsuario.fromJson(permMap, fallbackTipo: tipo);

    const sql = '''
      INSERT INTO funcoes (Nome, Tipo, Departamento, Criar_Tarefas, Editar_Tarefas, Excluir_Tarefas, Alterar_Status, Ver_Desempenho, Gerenciar_Permissoes)
      VALUES (:nome, :tipo, :depto, :criar, :editar, :excluir, :status, :desemp, :gerenc);
    ''';

    final res = await conn.execute(sql, {
      'nome': nome,
      'tipo': tipo,
      'depto': departamento,
      'criar': perms.criarTarefas ? 1 : 0,
      'editar': perms.editarTarefas ? 1 : 0,
      'excluir': perms.excluirTarefas ? 1 : 0,
      'status': perms.alterarStatus ? 1 : 0,
      'desemp': perms.verDesempenho ? 1 : 0,
      'gerenc': perms.gerenciarPermissoes ? 1 : 0,
    });

    final created = FuncaoModel(
      id: res.lastInsertID.toInt(),
      nome: nome,
      tipo: tipo,
      departamento: departamento,
      permissoes: perms,
    );
    return created.toJson();
  }

  Future<bool> excluir(int id) async {
    final conn = await Database.getConnection();
    await conn.execute('DELETE FROM funcoes WHERE Id = :id;', {'id': id});
    return true;
  }
}
