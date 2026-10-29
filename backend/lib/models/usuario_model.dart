class PermissoesUsuario {
  final bool criarTarefas;
  final bool editarTarefas;
  final bool excluirTarefas;
  final bool alterarStatus;
  final bool verDesempenho;
  final bool gerenciarPermissoes;

  const PermissoesUsuario({
    required this.criarTarefas,
    required this.editarTarefas,
    required this.excluirTarefas,
    required this.alterarStatus,
    required this.verDesempenho,
    required this.gerenciarPermissoes,
  });

  factory PermissoesUsuario.padraoPorTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'admin':
        return const PermissoesUsuario(
          criarTarefas: true,
          editarTarefas: true,
          excluirTarefas: true,
          alterarStatus: true,
          verDesempenho: true,
          gerenciarPermissoes: true,
        );
      case 'gestor':
        return const PermissoesUsuario(
          criarTarefas: true,
          editarTarefas: true,
          excluirTarefas: true,
          alterarStatus: true,
          verDesempenho: true,
          gerenciarPermissoes: false,
        );
      case 'analista':
        return const PermissoesUsuario(
          criarTarefas: true,
          editarTarefas: true,
          excluirTarefas: true,
          alterarStatus: true,
          verDesempenho: true,
          gerenciarPermissoes: false,
        );
      case 'assistente':
      case 'auxiliar':
      default:
        return const PermissoesUsuario(
          criarTarefas: false,
          editarTarefas: true,
          excluirTarefas: true,
          alterarStatus: true,
          verDesempenho: false,
          gerenciarPermissoes: false,
        );
    }
  }

  factory PermissoesUsuario.fromJson(Map<String, dynamic> json, {String fallbackTipo = 'auxiliar'}) {
    final padrao = PermissoesUsuario.padraoPorTipo(fallbackTipo);
    bool parseBool(dynamic v, bool fallback) {
      if (v == null) return fallback;
      if (v is bool) return v;
      if (v is int) return v != 0;
      final s = v.toString().toLowerCase();
      return s == 'true' || s == '1';
    }

    return PermissoesUsuario(
      criarTarefas: parseBool(json['criar_tarefas'], padrao.criarTarefas),
      editarTarefas: parseBool(json['editar_tarefas'], padrao.editarTarefas),
      excluirTarefas: parseBool(json['excluir_tarefas'], padrao.excluirTarefas),
      alterarStatus: parseBool(json['alterar_status'], padrao.alterarStatus),
      verDesempenho: parseBool(json['ver_desempenho'], padrao.verDesempenho),
      gerenciarPermissoes: parseBool(json['gerenciar_permissoes'], padrao.gerenciarPermissoes),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'criar_tarefas': criarTarefas,
      'editar_tarefas': editarTarefas,
      'excluir_tarefas': excluirTarefas,
      'alterar_status': alterarStatus,
      'ver_desempenho': verDesempenho,
      'gerenciar_permissoes': gerenciarPermissoes,
    };
  }
}

class UsuarioModel {
  final int? id;
  final String nome;
  final String tipo;
  final String? funcaoNome;
  final int? setorId;
  final String email;
  final String? telefone;
  final String? senha;
  final int? codigoAutenticacaoId;
  final String? codigoUtilizado;
  final PermissoesUsuario permissoes;

  UsuarioModel({
    this.id,
    required this.nome,
    required this.tipo,
    this.funcaoNome,
    this.setorId,
    required this.email,
    this.telefone,
    this.senha,
    this.codigoAutenticacaoId,
    this.codigoUtilizado,
    PermissoesUsuario? permissoes,
  }) : permissoes = permissoes ?? PermissoesUsuario.padraoPorTipo(tipo);

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    final tiposValidos = ['admin', 'gestor', 'analista', 'assistente', 'auxiliar'];
    final tipoInformado = (json['tipo']?.toString().toLowerCase() ?? 'assistente').trim();

    if (json['nome'] == null || json['nome'].toString().trim().isEmpty) {
      throw ArgumentError('O campo "nome" é obrigatório.');
    }
    if (json['email'] == null || json['email'].toString().trim().isEmpty) {
      throw ArgumentError('O campo "email" é obrigatório.');
    }
    if (json['senha'] == null || json['senha'].toString().trim().isEmpty) {
      throw ArgumentError('O campo "senha" é obrigatório.');
    }
    if (!tiposValidos.contains(tipoInformado)) {
      throw ArgumentError('O tipo deve ser: admin, gestor, analista, assistente ou auxiliar.');
    }

    PermissoesUsuario? perms;
    if (json['permissoes'] is Map<String, dynamic>) {
      perms = PermissoesUsuario.fromJson(
        json['permissoes'] as Map<String, dynamic>,
        fallbackTipo: tipoInformado,
      );
    }

    return UsuarioModel(
      id: json['id'] as int?,
      nome: json['nome'].toString().trim(),
      tipo: tipoInformado,
      funcaoNome: json['funcao_nome']?.toString().trim(),
      setorId: json['setor_id'] as int?,
      email: json['email'].toString().trim(),
      telefone: json['telefone'] as String?,
      senha: json['senha'] as String?,
      codigoAutenticacaoId: json['codigo_autenticacao_id'] as int?,
      codigoUtilizado: json['codigo_utilizado'] as String?,
      permissoes: perms,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo,
      'funcao_nome': funcaoNome,
      'setor_id': setorId,
      'email': email,
      'telefone': telefone,
      'codigo_autenticacao_id': codigoAutenticacaoId,
      'codigo_utilizado': codigoUtilizado,
      'permissoes': permissoes.toJson(),
    };
  }
}
