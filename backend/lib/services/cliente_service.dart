import '../config/database.dart';
import '../models/cliente_model.dart';

class ClienteService {
  static const String _colunas =
      'Id, Nome, CPF_CNPJ, E_mail, Endereco_Id, Telefone, Data_Criacao';

  Future<List<Map<String, dynamic>>> listarTodos() async {
    final conn = await Database.getConnection();
    const sql = '''
      SELECT $_colunas
      FROM clientes
      ORDER BY Id DESC;
    ''';
    final res = await conn.execute(sql);
    return res.rows.map((r) => ClienteModel.fromRow(r).toJson()).toList();
  }

  Future<Map<String, dynamic>> cadastrar(Map<String, dynamic> data) async {
    final conn = await Database.getConnection();
    final cliente = ClienteModel.fromJson(data);

    const sql = '''
      INSERT INTO clientes (Nome, CPF_CNPJ, E_mail, Telefone, Data_Criacao)
      VALUES (:nome, :cpf, :email, :telefone, CURDATE());
    ''';

    final res = await conn.execute(sql, {
      'nome': cliente.nome,
      'cpf': cliente.cpfCnpj,
      'email': cliente.email,
      'telefone': cliente.telefone,
    });

    final newId = res.lastInsertID.toInt();
    return ClienteModel(
      id: newId,
      nome: cliente.nome,
      cpfCnpj: cliente.cpfCnpj,
      email: cliente.email,
      telefone: cliente.telefone,
      dataCriacao: DateTime.now().toIso8601String().split('T').first,
    ).toJson();
  }

  Future<Map<String, dynamic>?> atualizar(
    int id,
    Map<String, dynamic> data,
  ) async {
    final conn = await Database.getConnection();
    final cliente = ClienteModel.fromJson(data);

    const sqlUpdate = '''
      UPDATE clientes
      SET Nome = :nome,
          CPF_CNPJ = :cpf,
          E_mail = :email,
          Telefone = :telefone
      WHERE Id = :id;
    ''';

    await conn.execute(sqlUpdate, {
      'nome': cliente.nome,
      'cpf': cliente.cpfCnpj,
      'email': cliente.email,
      'telefone': cliente.telefone,
      'id': id,
    });

    const sqlSelect = '''
      SELECT $_colunas
      FROM clientes
      WHERE Id = :id;
    ''';
    final res = await conn.execute(sqlSelect, {'id': id});
    if (res.rows.isEmpty) return null;

    return ClienteModel.fromRow(res.rows.first).toJson();
  }

  Future<bool> excluir(int id) async {
    final conn = await Database.getConnection();

    const sql = 'DELETE FROM clientes WHERE Id = :id;';
    final res = await conn.execute(sql, {'id': id});

    return res.affectedRows.toInt() > 0;
  }
}