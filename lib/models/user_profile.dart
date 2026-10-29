import 'permissao.dart';

export 'cliente.dart';
export 'job_function.dart';
export 'notificacao.dart';
export 'permissao.dart';
export 'task.dart';

enum AvatarChoice {
  person('Usuário Profissional'),
  initials('Iniciais'),
  badge('Crachá Corporativo'),
  admin('Gestor RH');

  const AvatarChoice(this.label);
  final String label;
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
    this.permissions = const UserPermissions(),
  });

  bool get isAdmin => tipo.toLowerCase() == 'admin' || permissions.funcionarios;

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
      name: json['nome']?.toString() ?? 'Funcionário Folks',
      email: json['email']?.toString() ?? '',
      tipo: tipo,
      role: (funcaoNome != null && funcaoNome.isNotEmpty) ? funcaoNome : roleLabelForTipo(tipo),
      department: departmentForTipo(tipo),
      phone: json['telefone']?.toString() ?? '(11) 98765-4321',
      bio: perms.funcionarios
          ? 'Acesso administrativo ao painel da Folks RH, gestão de permissões e configurações.'
          : 'Colaborador ativo no sistema Folks RH.',
      avatarChoice: perms.funcionarios ? AvatarChoice.admin : AvatarChoice.person,
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

/// Sessão do funcionário logado — sem usuários fixos de teste
class UserSession {
  static UserProfile? _current;

  static UserProfile? get currentOrNull => _current;

  static UserProfile get current {
    if (_current != null) return _current!;
    // Sessão padrão transitória caso ainda não autenticado
    return const UserProfile(
      id: 0,
      name: 'Não conectado',
      email: '',
      tipo: 'assistente',
      role: 'Visitante',
      department: 'Folks RH',
      phone: '',
      permissions: UserPermissions(
        clientes: false,
        tarefas: false,
        notificacoes: false,
        funcionarios: false,
        criarTarefas: false,
        editarTarefas: false,
        excluirTarefas: false,
        alterarStatus: false,
        verDesempenho: false,
      ),
    );
  }

  static set current(UserProfile profile) => setCurrent(profile);

  static bool get isLoggedIn => _current != null;

  static List<UserProfile> allUsers = [];

  static void setCurrent(UserProfile profile) {
    _current = profile;
    final idx = allUsers.indexWhere(
      (u) =>
          (profile.id != null && u.id == profile.id) ||
          u.email.toLowerCase() == profile.email.toLowerCase(),
    );
    if (idx != -1) {
      allUsers[idx] = profile;
    } else {
      allUsers.add(profile);
    }
  }

  static void logout() {
    _current = null;
  }
}
