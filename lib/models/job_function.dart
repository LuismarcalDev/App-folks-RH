import 'user_profile.dart';

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
      id: json['id'] is int
          ? json['id'] as int
          : (int.tryParse(json['id']?.toString() ?? '') ?? 1),
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

/// Sessão de funções cadastradas pelo Administrador
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
