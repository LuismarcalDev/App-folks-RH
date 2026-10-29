import '../config/database.dart';
import '../models/cliente_model.dart';

class ClienteService {
  Future<List<Map<String, dynamic>>> listarTodos() async {
    final conn = await Database.getConnection();
    const sql = '''
      SELECT Id, Nome, CPF_CNPJ, E_mail, Endereco_Id, Telefone, Data_Criacao
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
}
