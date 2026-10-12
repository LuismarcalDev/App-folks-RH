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
}
