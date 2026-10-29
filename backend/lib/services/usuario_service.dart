import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:mysql_client/mysql_client.dart';
import '../config/database.dart';
import '../models/usuario_model.dart';

class UsuarioService {
  String gerarHashSenha(String senhaPura) {
    final bytes = utf8.encode(senhaPura);
    return sha256.convert(bytes).toString();
  }

  UsuarioModel mapRowToUsuario(ResultSetRow row) {
    final id = int.tryParse(row.colByName('Id') ?? '');
    final nome = row.colByName('Nome') ?? '';
    final tipo = row.colByName('Tipo') ?? 'assistente';
    final setorId = int.tryParse(row.colByName('Setor_Id') ?? '');
    final email = row.colByName('E_mail') ?? '';
    final telefone = row.colByName('Telefone');
    final codigoAutenticacaoId = int.tryParse(row.colByName('Codigo_Autenticacao_Id') ?? '');
    final codigoUtilizado = row.colByName('Codigo_Utilizado');
    final funcaoNome = row.colByName('Funcao_Nome');

    final padrao = PermissoesUsuario.padraoPorTipo(tipo);
    bool toBool(String? val, bool fallback) {
      if (val == null) return fallback;
      return val == '1' || val.toLowerCase() == 'true';
    }

    final permissoes = PermissoesUsuario(
      clientes: toBool(row.colByName('Clientes'), padrao.clientes),
      tarefas: toBool(row.colByName('Tarefas'), padrao.tarefas),
      notificacoes: toBool(row.colByName('Notificacoes'), padrao.notificacoes),
      funcionarios: toBool(
        row.colByName('Funcionarios') ?? row.colByName('Gerenciar_Permissoes'),
        padrao.funcionarios,
      ),
      criarTarefas: toBool(row.colByName('Criar_Tarefas'), padrao.criarTarefas),
      editarTarefas: toBool(row.colByName('Editar_Tarefas'), padrao.editarTarefas),
      excluirTarefas: toBool(row.colByName('Excluir_Tarefas'), padrao.excluirTarefas),
      alterarStatus: toBool(row.colByName('Alterar_Status'), padrao.alterarStatus),
      verDesempenho: toBool(row.colByName('Ver_Desempenho'), padrao.verDesempenho),
    );

    return UsuarioModel(
      id: id,
      nome: nome,
      tipo: tipo,
      funcaoNome: funcaoNome,
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
    final senhaCriptografada = gerarHashSenha(usuario.senha ?? '1234');

    const sqlUsuario = '''
      INSERT INTO usuarios (
        Nome, Tipo, Funcao_Nome, Setor_Id, E_mail, Telefone, Senha, Codigo_Autenticacao_Id, Codigo_Utilizado
      ) VALUES (:nome, :tipo, :funcaoNome, :setorId, :email, :telefone, :senha, :codId, :codUtilizado);
    ''';

    final resultado = await conn.execute(sqlUsuario, {
      'nome': usuario.nome,
      'tipo': usuario.tipo,
      'funcaoNome': usuario.funcaoNome,
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
          Usuario_Id, Clientes, Tarefas, Notificacoes, Funcionarios,
          Criar_Tarefas, Editar_Tarefas, Excluir_Tarefas, Alterar_Status, Ver_Desempenho, Gerenciar_Permissoes
        ) VALUES (:uid, :clientes, :tarefas, :notificacoes, :funcionarios, :criar, :editar, :excluir, :status, :desempenho, :gerenciar)
        ON DUPLICATE KEY UPDATE
          Clientes = VALUES(Clientes),
          Tarefas = VALUES(Tarefas),
          Notificacoes = VALUES(Notificacoes),
          Funcionarios = VALUES(Funcionarios),
          Criar_Tarefas = VALUES(Criar_Tarefas),
          Editar_Tarefas = VALUES(Editar_Tarefas),
          Excluir_Tarefas = VALUES(Excluir_Tarefas),
          Alterar_Status = VALUES(Alterar_Status),
          Ver_Desempenho = VALUES(Ver_Desempenho),
          Gerenciar_Permissoes = VALUES(Gerenciar_Permissoes);
      ''';

      await conn.execute(sqlPerm, {
        'uid': novoId,
        'clientes': p.clientes ? 1 : 0,
        'tarefas': p.tarefas ? 1 : 0,
        'notificacoes': p.notificacoes ? 1 : 0,
        'funcionarios': p.funcionarios ? 1 : 0,
        'criar': p.criarTarefas ? 1 : 0,
        'editar': p.editarTarefas ? 1 : 0,
        'excluir': p.excluirTarefas ? 1 : 0,
        'status': p.alterarStatus ? 1 : 0,
        'desempenho': p.verDesempenho ? 1 : 0,
        'gerenciar': p.funcionarios ? 1 : 0,
      });
    }

    return UsuarioModel(
      id: novoId,
      nome: usuario.nome,
      tipo: usuario.tipo,
      funcaoNome: usuario.funcaoNome,
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
    final senhaCriptografada = gerarHashSenha(senha);
    final loginClean = emailOuLogin.trim().toLowerCase();

    const sql = '''
      SELECT u.Id, u.Nome, u.Tipo, u.Setor_Id, u.E_mail, u.Telefone, u.Codigo_Autenticacao_Id, u.Codigo_Utilizado,
             u.Funcao_Nome,
             p.Clientes, p.Tarefas, p.Notificacoes, p.Funcionarios,
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

    return mapRowToUsuario(resultado.rows.first);
  }

  Future<List<UsuarioModel>> listarTodos() async {
    final conn = await Database.getConnection();

    const sql = '''
      SELECT u.Id, u.Nome, u.Tipo, u.Setor_Id, u.E_mail, u.Telefone, u.Codigo_Autenticacao_Id, u.Codigo_Utilizado,
             u.Funcao_Nome,
             p.Clientes, p.Tarefas, p.Notificacoes, p.Funcionarios,
             p.Criar_Tarefas, p.Editar_Tarefas, p.Excluir_Tarefas, p.Alterar_Status, p.Ver_Desempenho, p.Gerenciar_Permissoes
      FROM usuarios u
      LEFT JOIN permissoes_usuario p ON p.Usuario_Id = u.Id
      ORDER BY u.Id ASC;
    ''';

    final resultado = await conn.execute(sql);
    return resultado.rows.map(mapRowToUsuario).toList();
  }

  Future<UsuarioModel?> buscarPorId(int id) async {
    final conn = await Database.getConnection();

    const sql = '''
      SELECT u.Id, u.Nome, u.Tipo, u.Setor_Id, u.E_mail, u.Telefone, u.Codigo_Autenticacao_Id, u.Codigo_Utilizado,
             u.Funcao_Nome,
             p.Clientes, p.Tarefas, p.Notificacoes, p.Funcionarios,
             p.Criar_Tarefas, p.Editar_Tarefas, p.Excluir_Tarefas, p.Alterar_Status, p.Ver_Desempenho, p.Gerenciar_Permissoes
      FROM usuarios u
      LEFT JOIN permissoes_usuario p ON p.Usuario_Id = u.Id
      WHERE u.Id = :id
      LIMIT 1;
    ''';

    final resultado = await conn.execute(sql, {'id': id});
    if (resultado.rows.isEmpty) return null;
    return mapRowToUsuario(resultado.rows.first);
  }

  Future<UsuarioModel?> atualizarPermissoes(
    int usuarioId, {
    String? tipo,
    String? funcaoNome,
    required PermissoesUsuario permissoes,
  }) async {
    final conn = await Database.getConnection();

    if (tipo != null && tipo.trim().isNotEmpty) {
      await conn.execute(
        'UPDATE usuarios SET Tipo = :tipo, Funcao_Nome = COALESCE(:funcaoNome, Funcao_Nome) WHERE Id = :id;',
        {'tipo': tipo.trim().toLowerCase(), 'funcaoNome': funcaoNome, 'id': usuarioId},
      );
    }

    const sqlPerm = '''
      INSERT INTO permissoes_usuario (
        Usuario_Id, Clientes, Tarefas, Notificacoes, Funcionarios,
        Criar_Tarefas, Editar_Tarefas, Excluir_Tarefas, Alterar_Status, Ver_Desempenho, Gerenciar_Permissoes
      ) VALUES (:uid, :clientes, :tarefas, :notificacoes, :funcionarios, :criar, :editar, :excluir, :status, :desempenho, :gerenciar)
      ON DUPLICATE KEY UPDATE
        Clientes = VALUES(Clientes),
        Tarefas = VALUES(Tarefas),
        Notificacoes = VALUES(Notificacoes),
        Funcionarios = VALUES(Funcionarios),
        Criar_Tarefas = VALUES(Criar_Tarefas),
        Editar_Tarefas = VALUES(Editar_Tarefas),
        Excluir_Tarefas = VALUES(Excluir_Tarefas),
        Alterar_Status = VALUES(Alterar_Status),
        Ver_Desempenho = VALUES(Ver_Desempenho),
        Gerenciar_Permissoes = VALUES(Gerenciar_Permissoes);
    ''';

    await conn.execute(sqlPerm, {
      'uid': usuarioId,
      'clientes': permissoes.clientes ? 1 : 0,
      'tarefas': permissoes.tarefas ? 1 : 0,
      'notificacoes': permissoes.notificacoes ? 1 : 0,
      'funcionarios': permissoes.funcionarios ? 1 : 0,
      'criar': permissoes.criarTarefas ? 1 : 0,
      'editar': permissoes.editarTarefas ? 1 : 0,
      'excluir': permissoes.excluirTarefas ? 1 : 0,
      'status': permissoes.alterarStatus ? 1 : 0,
      'desempenho': permissoes.verDesempenho ? 1 : 0,
      'gerenciar': permissoes.funcionarios ? 1 : 0,
    });

    return buscarPorId(usuarioId);
  }
}
