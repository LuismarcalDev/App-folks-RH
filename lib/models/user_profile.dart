enum AvatarChoice {
  person('Usuário Profissional'),
  initials('Iniciais'),
  badge('Crachá Corporativo'),
  admin('Gestor RH');

  const AvatarChoice(this.label);
  final String label;

  // Aliases para compatibilidade
  static const AvatarChoice both = AvatarChoice.person;
  static const AvatarChoice alien = AvatarChoice.initials;
  static const AvatarChoice skull = AvatarChoice.badge;
}

class UserProfile {
  final String name;
  final String email;
  final String role;
  final String department;
  final String phone;
  final String bio;
  final AvatarChoice avatarChoice;

  const UserProfile({
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.phone,
    this.bio = '',
    this.avatarChoice = AvatarChoice.person,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? role,
    String? department,
    String? phone,
    String? bio,
    AvatarChoice? avatarChoice,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      department: department ?? this.department,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      avatarChoice: avatarChoice ?? this.avatarChoice,
    );
  }
}

const alessandraProfile = UserProfile(
  name: 'Alessandra Gomes',
  email: 'alessandra.gomes@folksrh.com.br',
  role: 'Coordenadora de Recursos Humanos',
  department: 'Folks RH - Recrutamento & Seleção',
  phone: '(11) 97123-4567',
  bio: 'Especialista em recrutamento estratégico, atração de talentos e clima organizacional na Folks RH.',
  avatarChoice: AvatarChoice.person,
);

const igorProfile = UserProfile(
  name: 'Igor Veiga',
  email: 'igor.veiga@folksrh.com.br',
  role: 'Gestor de Recursos Humanos',
  department: 'Folks RH - Gestão & Operações',
  phone: '(11) 98765-4321',
  bio: 'Responsável pelo gerenciamento de processos seletivos, triagem de talentos e acompanhamento de equipes na Folks RH.',
  avatarChoice: AvatarChoice.person,
);

const admProfile = UserProfile(
  name: 'Administrador (Folks RH)',
  email: 'adm@folksrh.com.br',
  role: 'Administrador do Sistema',
  department: 'Folks RH - Diretoria & Tecnologia',
  phone: '(11) 99888-0001',
  bio: 'Acesso administrativo global ao painel da Folks RH, gestão de permissões, indicadores e configurações.',
  avatarChoice: AvatarChoice.admin,
);

const defaultUserProfile = igorProfile;

/// Sessão do usuário logado no aplicativo
class UserSession {
  static UserProfile current = alessandraProfile;

  static void login(String username) {
    final u = username.toLowerCase().trim();
    if (u.contains('alessandra')) {
      current = alessandraProfile;
    } else if (u.contains('adm')) {
      current = admProfile;
    } else if (u.contains('igor')) {
      current = igorProfile;
    } else {
      current = UserProfile(
        name: username,
        email: '$u@folksrh.com.br',
        role: 'Colaborador Folks RH',
        department: 'Folks RH - Recursos Humanos',
        phone: '(11) 98765-4321',
        bio: 'Membro da equipe Folks RH.',
        avatarChoice: AvatarChoice.person,
      );
    }
  }
}


