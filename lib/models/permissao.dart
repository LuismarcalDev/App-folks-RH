class UserPermissions {
  final bool clientes;
  final bool tarefas;
  final bool notificacoes;
  final bool funcionarios;

  // Sub-permissões detalhadas de tarefas
  final bool criarTarefas;
  final bool editarTarefas;
  final bool excluirTarefas;
  final bool alterarStatus;
  final bool verDesempenho;

  bool get gerenciarPermissoes => funcionarios;

  const UserPermissions({
    this.clientes = true,
    this.tarefas = true,
    this.notificacoes = true,
    bool funcionarios = false,
    bool? gerenciarPermissoes,
    this.criarTarefas = false,
    this.editarTarefas = true,
    this.excluirTarefas = true,
    this.alterarStatus = true,
    this.verDesempenho = false,
  }) : funcionarios = funcionarios || (gerenciarPermissoes ?? false);

  factory UserPermissions.forTipo(String tipo) {
    switch (tipo.toLowerCase().trim()) {
      case 'admin':
        return const UserPermissions(
          clientes: true,
          tarefas: true,
          notificacoes: true,
          funcionarios: true,
          criarTarefas: true,
          editarTarefas: true,
          excluirTarefas: true,
          alterarStatus: true,
          verDesempenho: true,
        );
      case 'gestor':
        return const UserPermissions(
          clientes: true,
          tarefas: true,
          notificacoes: true,
          funcionarios: true,
          criarTarefas: true,
          editarTarefas: true,
          excluirTarefas: true,
          alterarStatus: true,
          verDesempenho: true,
        );
      case 'analista':
        return const UserPermissions(
          clientes: true,
          tarefas: true,
          notificacoes: true,
          funcionarios: false,
          criarTarefas: true,
          editarTarefas: true,
          excluirTarefas: true,
          alterarStatus: true,
          verDesempenho: true,
        );
      case 'assistente':
      case 'auxiliar':
      default:
        return const UserPermissions(
          clientes: true,
          tarefas: true,
          notificacoes: true,
          funcionarios: false,
          criarTarefas: false,
          editarTarefas: true,
          excluirTarefas: true,
          alterarStatus: true,
          verDesempenho: false,
        );
    }
  }

  factory UserPermissions.fromJson(
    Map<String, dynamic> json, {
    String fallbackTipo = 'assistente',
  }) {
    final fallback = UserPermissions.forTipo(fallbackTipo);
    bool parseBool(dynamic v, bool def) {
      if (v == null) return def;
      if (v is bool) return v;
      if (v is int) return v != 0;
      final s = v.toString().toLowerCase();
      return s == 'true' || s == '1';
    }

    return UserPermissions(
      clientes: parseBool(json['clientes'], fallback.clientes),
      tarefas: parseBool(json['tarefas'], fallback.tarefas),
      notificacoes: parseBool(json['notificacoes'], fallback.notificacoes),
      funcionarios: parseBool(
        json['funcionarios'] ?? json['gerenciar_permissoes'],
        fallback.funcionarios,
      ),
      criarTarefas: parseBool(json['criar_tarefas'], fallback.criarTarefas),
      editarTarefas: parseBool(json['editar_tarefas'], fallback.editarTarefas),
      excluirTarefas: parseBool(json['excluir_tarefas'], fallback.excluirTarefas),
      alterarStatus: parseBool(json['alterar_status'], fallback.alterarStatus),
      verDesempenho: parseBool(json['ver_desempenho'], fallback.verDesempenho),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientes': clientes,
      'tarefas': tarefas,
      'notificacoes': notificacoes,
      'funcionarios': funcionarios,
      'criar_tarefas': criarTarefas,
      'editar_tarefas': editarTarefas,
      'excluir_tarefas': excluirTarefas,
      'alterar_status': alterarStatus,
      'ver_desempenho': verDesempenho,
      'gerenciar_permissoes': funcionarios,
    };
  }

  UserPermissions copyWith({
    bool? clientes,
    bool? tarefas,
    bool? notificacoes,
    bool? funcionarios,
    bool? gerenciarPermissoes,
    bool? criarTarefas,
    bool? editarTarefas,
    bool? excluirTarefas,
    bool? alterarStatus,
    bool? verDesempenho,
  }) {
    return UserPermissions(
      clientes: clientes ?? this.clientes,
      tarefas: tarefas ?? this.tarefas,
      notificacoes: notificacoes ?? this.notificacoes,
      funcionarios: gerenciarPermissoes ?? funcionarios ?? this.funcionarios,
      criarTarefas: criarTarefas ?? this.criarTarefas,
      editarTarefas: editarTarefas ?? this.editarTarefas,
      excluirTarefas: excluirTarefas ?? this.excluirTarefas,
      alterarStatus: alterarStatus ?? this.alterarStatus,
      verDesempenho: verDesempenho ?? this.verDesempenho,
    );
  }
}
