import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:mysql_client/mysql_client.dart';
import '../config/database.dart';
import '../models/usuario_model.dart';

class UsuarioService {
  String _gerarHashSenha(String senhaPura) {
    final bytes = utf8.encode(senhaPura);
    return sha256.convert(bytes).toString();
  }

  UsuarioModel _mapRowToUsuario(ResultSetRow row) {
    final id = int.tryParse(row.colAt(0) ?? '');
    final nome = row.colAt(1) ?? '';
    final tipo = row.colAt(2) ?? 'assistente';
    final setorId = int.tryParse(row.colAt(3) ?? '');
    final email = row.colAt(4) ?? '';
    final telefone = row.colAt(5);
    final codigoAutenticacaoId = int.tryParse(row.colAt(6) ?? '');
    final codigoUtilizado = row.colAt(7);

    final padrao = PermissoesUsuario.padraoPorTipo(tipo);
    bool toBool(String? val, bool fallback) {
      if (val == null) return fallback;
      return val == '1' || val.toLowerCase() == 'true';
    }

    final permissoes = PermissoesUsuario(
      criarTarefas: toBool(row.colAt(8), padrao.criarTarefas),
      editarTarefas: toBool(row.colAt(9), padrao.editarTarefas),
      excluirTarefas: toBool(row.colAt(10), padrao.excluirTarefas),
      alterarStatus: toBool(row.colAt(11), padrao.alterarStatus),
      verDesempenho: toBool(row.colAt(12), padrao.verDesempenho),
      gerenciarPermissoes: toBool(row.colAt(13), padrao.gerenciarPermissoes),
    );

    return UsuarioModel(
      id: id,
      nome: nome,
      tipo: tipo,
      setorId: setorId,
      email: email,
      telefone: telefone,
      codigoAutenticacaoId: codigoAutenticacaoId,
      codigoUtilizado: codigoUtilizado,
      permissoes: permissoes,
    );
  }

  Future<UsuarioModel> cadastrar(UsuarioModel usuario) async {
    final conn = await Database.getConnection();

    final senhaCriptografada = _gerarHashSenha(usuario.senha!);

    const sqlUsuario = '''
      INSERT INTO usuarios (
        Nome, Tipo, Setor_Id, E_mail, Telefone, Senha, Codigo_Autenticacao_Id, Codigo_Utilizado
      ) VALUES (:nome, :tipo, :setorId, :email, :telefone, :senha, :codId, :codUtilizado);
    ''';

    final resultado = await conn.execute(sqlUsuario, {
      'nome': usuario.nome,
      'tipo': usuario.tipo,
      'setorId': usuario.setorId,
      'email': usuario.email,
      'telefone': usuario.telefone,
      'senha': senhaCriptografada,
      'codId': usuario.codigoAutenticacaoId,
      'codUtilizado': usuario.codigoUtilizado,
    });

    final novoId = resultado.lastInsertID.toInt();
    final p = usuario.permissoes;

    if (novoId > 0) {
      const sqlPerm = '''
        INSERT INTO permissoes_usuario (
          Usuario_Id, Criar_Tarefas, Editar_Tarefas, Excluir_Tarefas, Alterar_Status, Ver_Desempenho, Gerenciar_Permissoes
        ) VALUES (:uid, :criar, :editar, :excluir, :status, :desempenho, :gerenciar)
        ON DUPLICATE KEY UPDATE
          Criar_Tarefas = VALUES(Criar_Tarefas),
          Editar_Tarefas = VALUES(Editar_Tarefas),
          Excluir_Tarefas = VALUES(Excluir_Tarefas),
          Alterar_Status = VALUES(Alterar_Status),
          Ver_Desempenho = VALUES(Ver_Desempenho),
          Gerenciar_Permissoes = VALUES(Gerenciar_Permissoes);
      ''';
      await conn.execute(sqlPerm, {
        'uid': novoId,
        'criar': p.criarTarefas ? 1 : 0,
        'editar': p.editarTarefas ? 1 : 0,
        'excluir': p.excluirTarefas ? 1 : 0,
        'status': p.alterarStatus ? 1 : 0,
        'desempenho': p.verDesempenho ? 1 : 0,
        'gerenciar': p.gerenciarPermissoes ? 1 : 0,
      });
    }

    return UsuarioModel(
      id: novoId,
      nome: usuario.nome,
      tipo: usuario.tipo,
      setorId: usuario.setorId,
      email: usuario.email,
      telefone: usuario.telefone,
      codigoAutenticacaoId: usuario.codigoAutenticacaoId,
      codigoUtilizado: usuario.codigoUtilizado,
      permissoes: p,
    );
  }

  Future<UsuarioModel?> autenticar(String emailOuLogin, String senha) async {
    final conn = await Database.getConnection();
    final senhaCriptografada = _gerarHashSenha(senha);
    final loginClean = emailOuLogin.trim().toLowerCase();

    const sql = '''
      SELECT u.Id, u.Nome, u.Tipo, u.Setor_Id, u.E_mail, u.Telefone, u.Codigo_Autenticacao_Id, u.Codigo_Utilizado,
             p.Criar_Tarefas, p.Editar_Tarefas, p.Excluir_Tarefas, p.Alterar_Status, p.Ver_Desempenho, p.Gerenciar_Permissoes
      FROM usuarios u
      LEFT JOIN permissoes_usuario p ON p.Usuario_Id = u.Id
      WHERE (
        LOWER(u.E_mail) = :login
        OR LOWER(u.Nome) = :login
        OR LOWER(SUBSTRING_INDEX(u.E_mail, '@', 1)) = :login
        OR LOWER(SUBSTRING_INDEX(u.Nome, ' ', 1)) = :login
      ) AND (u.Senha = :senhaHash OR u.Senha = :senhaPura)
      LIMIT 1;
    ''';

    final resultado = await conn.execute(sql, {
      'login': loginClean,
      'senhaHash': senhaCriptografada,
      'senhaPura': senha,
    });

    if (resultado.rows.isEmpty) {
      return null;
    }

    return _mapRowToUsuario(resultado.rows.first);
  }

  Future<List<UsuarioModel>> listarTodos() async {
    final conn = await Database.getConnection();

    const sql = '''
      SELECT u.Id, u.Nome, u.Tipo, u.Setor_Id, u.E_mail, u.Telefone, u.Codigo_Autenticacao_Id, u.Codigo_Utilizado,
             p.Criar_Tarefas, p.Editar_Tarefas, p.Excluir_Tarefas, p.Alterar_Status, p.Ver_Desempenho, p.Gerenciar_Permissoes
      FROM usuarios u
      LEFT JOIN permissoes_usuario p ON p.Usuario_Id = u.Id
      ORDER BY u.Id ASC;
    ''';

    final resultado = await conn.execute(sql);
    return resultado.rows.map(_mapRowToUsuario).toList();
  }

  Future<UsuarioModel?> buscarPorId(int id) async {
    final conn = await Database.getConnection();

    const sql = '''
      SELECT u.Id, u.Nome, u.Tipo, u.Setor_Id, u.E_mail, u.Telefone, u.Codigo_Autenticacao_Id, u.Codigo_Utilizado,
             p.Criar_Tarefas, p.Editar_Tarefas, p.Excluir_Tarefas, p.Alterar_Status, p.Ver_Desempenho, p.Gerenciar_Permissoes
      FROM usuarios u
      LEFT JOIN permissoes_usuario p ON p.Usuario_Id = u.Id
      WHERE u.Id = :id
      LIMIT 1;
    ''';

    final resultado = await conn.execute(sql, {'id': id});
    if (resultado.rows.isEmpty) return null;
    return _mapRowToUsuario(resultado.rows.first);
  }

  Future<UsuarioModel?> atualizarPermissoes(
    int usuarioId, {
    String? tipo,
    required PermissoesUsuario permissoes,
  }) async {
    final conn = await Database.getConnection();

    if (tipo != null && tipo.trim().isNotEmpty) {
      await conn.execute(
        'UPDATE usuarios SET Tipo = :tipo WHERE Id = :id;',
        {'tipo': tipo.trim().toLowerCase(), 'id': usuarioId},
      );
    }

    const sqlPerm = '''
      INSERT INTO permissoes_usuario (
        Usuario_Id, Criar_Tarefas, Editar_Tarefas, Excluir_Tarefas, Alterar_Status, Ver_Desempenho, Gerenciar_Permissoes
      ) VALUES (:uid, :criar, :editar, :excluir, :status, :desempenho, :gerenciar)
      ON DUPLICATE KEY UPDATE
        Criar_Tarefas = VALUES(Criar_Tarefas),
        Editar_Tarefas = VALUES(Editar_Tarefas),
        Excluir_Tarefas = VALUES(Excluir_Tarefas),
        Alterar_Status = VALUES(Alterar_Status),
        Ver_Desempenho = VALUES(Ver_Desempenho),
        Gerenciar_Permissoes = VALUES(Gerenciar_Permissoes);
    ''';

    await conn.execute(sqlPerm, {
      'uid': usuarioId,
      'criar': permissoes.criarTarefas ? 1 : 0,
      'editar': permissoes.editarTarefas ? 1 : 0,
      'excluir': permissoes.excluirTarefas ? 1 : 0,
      'status': permissoes.alterarStatus ? 1 : 0,
      'desempenho': permissoes.verDesempenho ? 1 : 0,
      'gerenciar': permissoes.gerenciarPermissoes ? 1 : 0,
    });

    return buscarPorId(usuarioId);
  }
}
