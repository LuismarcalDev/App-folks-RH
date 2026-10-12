import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../config/database.dart';
import '../models/usuario_model.dart';

class UsuarioService {
  String _gerarHashSenha(String senhaPura) {
    final bytes = utf8.encode(senhaPura);
    return sha256.convert(bytes).toString();
  }

  Future<UsuarioModel> cadastrar(UsuarioModel usuario) async {
    final conn = await Database.getConnection();

    final senhaCriptografada = _gerarHashSenha(usuario.senha!);

    const sql = '''
      INSERT INTO Usuarios (
        Nome, Tipo, Setor_Id, E_mail, Telefone, Senha, Codigo_Autenticacao_Id, Codigo_Utilizado
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?);
    ''';

    final resultado = await conn.query(sql, [
      usuario.nome,
      usuario.tipo,
      usuario.setorId,
      usuario.email,
      usuario.telefone,
      senhaCriptografada,
      usuario.codigoAutenticacaoId,
      usuario.codigoUtilizado,
    ]);

    final novoId = resultado.insertId;

    return UsuarioModel(
      id: novoId,
      nome: usuario.nome,
      tipo: usuario.tipo,
      setorId: usuario.setorId,
      email: usuario.email,
      telefone: usuario.telefone,
      codigoAutenticacaoId: usuario.codigoAutenticacaoId,
      codigoUtilizado: usuario.codigoUtilizado,
    );
  }

  Future<UsuarioModel?> autenticar(String emailOuLogin, String senha) async {
    final conn = await Database.getConnection();
    final senhaCriptografada = _gerarHashSenha(senha);

    const sql = '''
      SELECT Id, Nome, Tipo, Setor_Id, E_mail, Telefone, Codigo_Autenticacao_Id, Codigo_Utilizado
      FROM Usuarios
      WHERE (E_mail = ? OR Nome = ?) AND Senha = ?
      LIMIT 1;
    ''';

    final resultado = await conn.query(sql, [
      emailOuLogin,
      emailOuLogin,
      senhaCriptografada,
    ]);

    if (resultado.isEmpty) {
      return null;
    }

    final row = resultado.first;

    return UsuarioModel(
      id: row[0] as int?,
      nome: row[1]?.toString() ?? '',
      tipo: row[2]?.toString() ?? '',
      setorId: row[3] as int?,
      email: row[4]?.toString() ?? '',
      telefone: row[5]?.toString(),
      codigoAutenticacaoId: row[6] as int?,
      codigoUtilizado: row[7]?.toString(),
    );
  }
}
