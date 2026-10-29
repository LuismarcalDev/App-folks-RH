class PermissoesUsuario {
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

  const PermissoesUsuario({
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

  static bool parseBool(dynamic value, bool fallback) {
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is int) return value != 0;
    final s = value.toString().toLowerCase().trim();
    return s == 'true' || s == '1';
  }

  factory PermissoesUsuario.padraoPorTipo(String tipo) {
    switch (tipo.toLowerCase().trim()) {
      case 'admin':
        return const PermissoesUsuario(
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
        return const PermissoesUsuario(
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
        return const PermissoesUsuario(
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
        return const PermissoesUsuario(
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

  factory PermissoesUsuario.fromJson(
    Map<String, dynamic> json, {
    String fallbackTipo = 'assistente',
  }) {
    final padrao = PermissoesUsuario.padraoPorTipo(fallbackTipo);
    return PermissoesUsuario(
      clientes: parseBool(json['clientes'], padrao.clientes),
      tarefas: parseBool(json['tarefas'], padrao.tarefas),
      notificacoes: parseBool(json['notificacoes'], padrao.notificacoes),
      funcionarios: parseBool(
        json['funcionarios'] ?? json['gerenciar_permissoes'],
        padrao.funcionarios,
      ),
      criarTarefas: parseBool(json['criar_tarefas'], padrao.criarTarefas),
      editarTarefas: parseBool(json['editar_tarefas'], padrao.editarTarefas),
      excluirTarefas: parseBool(json['excluir_tarefas'], padrao.excluirTarefas),
      alterarStatus: parseBool(json['alterar_status'], padrao.alterarStatus),
      verDesempenho: parseBool(json['ver_desempenho'], padrao.verDesempenho),
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
}
