class Cliente {
  final int? id;
  final String nome;
  final String? cpfCnpj;
  final String? email;
  final String? telefone;
  final DateTime? dataCriacao;

  const Cliente({
    this.id,
    required this.nome,
    this.cpfCnpj,
    this.email,
    this.telefone,
    this.dataCriacao,
  });

  static String? _str(dynamic v) {
    final s = v?.toString().trim();
    return (s == null || s.isEmpty) ? null : s;
  }

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: int.tryParse(json['id']?.toString() ?? ''),
      nome: _str(json['nome']) ?? 'Cliente sem nome',
      cpfCnpj: _str(json['cpf_cnpj']),
      email: _str(json['email']),
      telefone: _str(json['telefone']),
      dataCriacao: DateTime.tryParse(json['data_criacao']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'cpf_cnpj': cpfCnpj,
        'email': email,
        'telefone': telefone,
      };

  Cliente copyWith({
    int? id,
    String? nome,
    String? cpfCnpj,
    String? email,
    String? telefone,
    DateTime? dataCriacao,
  }) {
    return Cliente(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      cpfCnpj: cpfCnpj ?? this.cpfCnpj,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }
}