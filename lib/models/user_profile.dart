enum AvatarChoice {
  person('Usuário Profissional'),
  initials('Iniciais'),
  badge('Crachá Corporativo'),
  admin('Gestor RH');

  const AvatarChoice(this.label);
  final String label;
}

class UserPermissions {
  final bool criarTarefas;
  final bool editarTarefas;
  final bool excluirTarefas;
  final bool alterarStatus;
  final bool verDesempenho;
  final bool gerenciarPermissoes;

  const UserPermissions({
    required this.criarTarefas,
    required this.editarTarefas,
    required this.excluirTarefas,
    required this.alterarStatus,
    required this.verDesempenho,
    required this.gerenciarPermissoes,
  });

  factory UserPermissions.forTipo(String tipo) {
    switch (tipo.toLowerCase().trim()) {
      case 'admin':
        return const UserPermissions(
          criarTarefas: true,
          editarTarefas: true,
          excluirTarefas: true,
          alterarStatus: true,
          verDesempenho: true,
          gerenciarPermissoes: true,
        );
      case 'gestor':
        return const UserPermissions(
          criarTarefas: true,
          editarTarefas: true,
          excluirTarefas: true,
          alterarStatus: true,
          verDesempenho: true,
          gerenciarPermissoes: false,
        );
      case 'analista':
        return const UserPermissions(
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
        return const UserPermissions(
          criarTarefas: false,
          editarTarefas: true,
          excluirTarefas: true,
          alterarStatus: true,
          verDesempenho: false,
          gerenciarPermissoes: false,
        );
    }
  }

  factory UserPermissions.fromJson(Map<String, dynamic> json, {String fallbackTipo = 'assistente'}) {
    final fallback = UserPermissions.forTipo(fallbackTipo);
    bool parseBool(dynamic v, bool def) {
      if (v == null) return def;
      if (v is bool) return v;
      if (v is int) return v != 0;
      final s = v.toString().toLowerCase();
      return s == 'true' || s == '1';
    }

    return UserPermissions(
      criarTarefas: parseBool(json['criar_tarefas'], fallback.criarTarefas),
      editarTarefas: parseBool(json['editar_tarefas'], fallback.editarTarefas),
      excluirTarefas: parseBool(json['excluir_tarefas'], fallback.excluirTarefas),
      alterarStatus: parseBool(json['alterar_status'], fallback.alterarStatus),
      verDesempenho: parseBool(json['ver_desempenho'], fallback.verDesempenho),
      gerenciarPermissoes: parseBool(json['gerenciar_permissoes'], fallback.gerenciarPermissoes),
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

  UserPermissions copyWith({
    bool? criarTarefas,
    bool? editarTarefas,
    bool? excluirTarefas,
    bool? alterarStatus,
    bool? verDesempenho,
    bool? gerenciarPermissoes,
  }) {
    return UserPermissions(
      criarTarefas: criarTarefas ?? this.criarTarefas,
      editarTarefas: editarTarefas ?? this.editarTarefas,
      excluirTarefas: excluirTarefas ?? this.excluirTarefas,
      alterarStatus: alterarStatus ?? this.alterarStatus,
      verDesempenho: verDesempenho ?? this.verDesempenho,
      gerenciarPermissoes: gerenciarPermissoes ?? this.gerenciarPermissoes,
    );
  }
}

/// Modelo de Função/Cargo cadastrado pelo Administrador
class JobFunction {
  final int id;
  final String nome;
  final String tipo;
  final String departamento;
  final UserPermissions permissions;

  const JobFunction({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.departamento,
    required this.permissions,
  });

  factory JobFunction.fromJson(Map<String, dynamic> json) {
    final tipo = (json['tipo']?.toString().toLowerCase() ?? 'assistente').trim();
    final permMap = json['permissoes'] is Map<String, dynamic>
        ? json['permissoes'] as Map<String, dynamic>
        : <String, dynamic>{};
    return JobFunction(
      id: json['id'] is int ? json['id'] as int : (int.tryParse(json['id']?.toString() ?? '') ?? 1),
      nome: (json['nome'] ?? 'Assistente de RH').toString(),
      tipo: tipo,
      departamento: (json['departamento'] ?? UserProfile.departmentForTipo(tipo)).toString(),
      permissions: UserPermissions.fromJson(permMap, fallbackTipo: tipo),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo,
      'departamento': departamento,
      'permissoes': permissions.toJson(),
    };
  }
}

class FunctionSession {
  static List<JobFunction> functions = [
    JobFunction(
      id: 1,
      nome: 'Gestor de Recursos Humanos',
      tipo: 'gestor',
      departamento: 'Folks RH - Gestão & Operações',
      permissions: UserPermissions.forTipo('gestor'),
    ),
    JobFunction(
      id: 2,
      nome: 'Analista de Recrutamento & Seleção',
      tipo: 'analista',
      departamento: 'Folks RH - Recrutamento & Seleção',
      permissions: UserPermissions.forTipo('analista'),
    ),
    JobFunction(
      id: 3,
      nome: 'Tech Recruiter',
      tipo: 'analista',
      departamento: 'Folks RH - Tecnologia & Talentos',
      permissions: UserPermissions.forTipo('analista'),
    ),
    JobFunction(
      id: 4,
      nome: 'Assistente de Recursos Humanos',
      tipo: 'assistente',
      departamento: 'Folks RH - Recrutamento & Seleção',
      permissions: UserPermissions.forTipo('assistente'),
    ),
    JobFunction(
      id: 5,
      nome: 'Auxiliar Administrativo de RH',
      tipo: 'auxiliar',
      departamento: 'Folks RH - Departamento Pessoal',
      permissions: UserPermissions.forTipo('auxiliar'),
    ),
  ];
}

class UserProfile {
  final int? id;
  final String name;
  final String email;
  final String tipo;
  final String role;
  final String department;
  final String phone;
  final String bio;
  final AvatarChoice avatarChoice;
  final UserPermissions permissions;

  const UserProfile({
    this.id,
    required this.name,
    required this.email,
    this.tipo = 'assistente',
    required this.role,
    required this.department,
    required this.phone,
    this.bio = '',
    this.avatarChoice = AvatarChoice.person,
    this.permissions = const UserPermissions(
      criarTarefas: false,
      editarTarefas: true,
      excluirTarefas: true,
      alterarStatus: true,
      verDesempenho: false,
      gerenciarPermissoes: false,
    ),
  });

  bool get isAdmin => tipo.toLowerCase() == 'admin' || permissions.gerenciarPermissoes;

  static String roleLabelForTipo(String tipo) {
    switch (tipo.toLowerCase().trim()) {
      case 'admin':
        return 'Administrador do Sistema';
      case 'gestor':
        return 'Gestor de Recursos Humanos';
      case 'analista':
        return 'Analista de Recursos Humanos';
      case 'assistente':
        return 'Assistente de Recursos Humanos';
      case 'auxiliar':
      default:
        return 'Auxiliar de Recursos Humanos';
    }
  }

  static String departmentForTipo(String tipo) {
    switch (tipo.toLowerCase().trim()) {
      case 'admin':
        return 'Folks RH - Diretoria & Tecnologia';
      case 'gestor':
        return 'Folks RH - Gestão & Operações';
      default:
        return 'Folks RH - Recrutamento & Seleção';
    }
  }

  factory UserProfile.fromBackendJson(Map<String, dynamic> json) {
    final tipo = (json['tipo']?.toString().toLowerCase() ?? 'assistente').trim();
    final funcaoNome = json['funcao_nome']?.toString().trim();
    final permMap = json['permissoes'] is Map<String, dynamic>
        ? json['permissoes'] as Map<String, dynamic>
        : <String, dynamic>{};
    final perms = UserPermissions.fromJson(permMap, fallbackTipo: tipo);

    return UserProfile(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      name: json['nome']?.toString() ?? 'Usuário Folks',
      email: json['email']?.toString() ?? '',
      tipo: tipo,
      role: (funcaoNome != null && funcaoNome.isNotEmpty) ? funcaoNome : roleLabelForTipo(tipo),
      department: departmentForTipo(tipo),
      phone: json['telefone']?.toString() ?? '(11) 98765-4321',
      bio: perms.gerenciarPermissoes
          ? 'Acesso administrativo global ao painel da Folks RH, gestão de permissões, indicadores e configurações.'
          : 'Colaborador ativo no sistema Folks RH.',
      avatarChoice: perms.gerenciarPermissoes ? AvatarChoice.admin : AvatarChoice.person,
      permissions: perms,
    );
  }

  String get initials {
    final clean = name.split('(').first.trim().replaceAll('-', ' ');
    final parts = clean.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'RH';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : parts[0].length).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  UserProfile copyWith({
    int? id,
    String? name,
    String? email,
    String? tipo,
    String? role,
    String? department,
    String? phone,
    String? bio,
    AvatarChoice? avatarChoice,
    UserPermissions? permissions,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      tipo: tipo ?? this.tipo,
      role: role ?? this.role,
      department: department ?? this.department,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      avatarChoice: avatarChoice ?? this.avatarChoice,
      permissions: permissions ?? this.permissions,
    );
  }
}

const luisProfile = UserProfile(
  id: 1,
  name: 'Luis',
  email: 'luis@folksrh.com.br',
  tipo: 'admin',
  role: 'Administrador do Sistema',
  department: 'Folks RH - Diretoria & Tecnologia',
  phone: '(11) 98765-4321',
  bio: 'Acesso administrativo global ao painel da Folks RH, gestão de permissões, indicadores e configurações.',
  avatarChoice: AvatarChoice.admin,
  permissions: UserPermissions(
    criarTarefas: true,
    editarTarefas: true,
    excluirTarefas: true,
    alterarStatus: true,
    verDesempenho: true,
    gerenciarPermissoes: true,
  ),
);

const igorProfile = UserProfile(
  id: 2,
  name: 'Igor Veiga',
  email: 'igor@folksrh.com.br',
  tipo: 'gestor',
  role: 'Gestor de Recursos Humanos',
  department: 'Folks RH - Gestão & Operações',
  phone: '(11) 98765-4321',
  bio: 'Responsável pelo gerenciamento de processos seletivos, triagem de talentos e acompanhamento de equipes na Folks RH.',
  avatarChoice: AvatarChoice.person,
  permissions: UserPermissions(
    criarTarefas: true,
    editarTarefas: true,
    excluirTarefas: true,
    alterarStatus: true,
    verDesempenho: true,
    gerenciarPermissoes: false,
  ),
);

const alessandraProfile = UserProfile(
  id: 3,
  name: 'Alessandra Gomes',
  email: 'alessandra@folksrh.com.br',
  tipo: 'assistente',
  role: 'Assistente de Recursos Humanos',
  department: 'Folks RH - Recrutamento & Seleção',
  phone: '(11) 97123-4567',
  bio: 'Atuação operacional na atualização de status de tarefas e suporte aos processos seletivos na Folks RH.',
  avatarChoice: AvatarChoice.person,
  permissions: UserPermissions(
    criarTarefas: false,
    editarTarefas: true,
    excluirTarefas: true,
    alterarStatus: true,
    verDesempenho: false,
    gerenciarPermissoes: false,
  ),
);

const admProfile = luisProfile;
const defaultUserProfile = luisProfile;

/// Sessão do usuário logado no aplicativo
class UserSession {
  static UserProfile current = luisProfile;

  static List<UserProfile> allUsers = [
    luisProfile,
    igorProfile,
    alessandraProfile,
  ];

  static void setCurrent(UserProfile profile) {
    current = profile;
    final idx = allUsers.indexWhere(
      (u) => (profile.id != null && u.id == profile.id) || u.email.toLowerCase() == profile.email.toLowerCase(),
    );
    if (idx != -1) {
      allUsers[idx] = profile;
    } else {
      allUsers.add(profile);
    }
  }

  static void login(String username) {
    final u = username.toLowerCase().trim();
    final matched = allUsers.where((profile) {
      final emailLower = profile.email.toLowerCase();
      final emailPrefix = emailLower.split('@').first;
      final nameLower = profile.name.toLowerCase();
      final firstName = nameLower.split(' ').first;
      return emailLower == u || emailPrefix == u || nameLower == u || firstName == u;
    });

    if (matched.isNotEmpty) {
      current = matched.first;
    } else if (u.contains('luis') || u.contains('adm')) {
      current = luisProfile;
    } else if (u.contains('igor') || u.contains('gestor')) {
      current = igorProfile;
    } else if (u.contains('alessandra') || u.contains('assistente')) {
      current = alessandraProfile;
    } else {
      current = UserProfile(
        name: username,
        email: '$u@folksrh.com.br',
        tipo: 'assistente',
        role: 'Assistente de Recursos Humanos',
        department: 'Folks RH - Recursos Humanos',
        phone: '(11) 98765-4321',
        bio: 'Membro da equipe Folks RH.',
        avatarChoice: AvatarChoice.person,
      );
    }
  }
}
