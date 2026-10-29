class Cliente {
  final int? id;
  final String nome;
  final String? cpfCnpj;
  final String? email;
  final String? telefone;
  final String? dataCriacao;

  const Cliente({
    this.id,
    required this.nome,
    this.cpfCnpj,
    this.email,
    this.telefone,
    this.dataCriacao,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      nome: (json['nome'] ?? 'Cliente').toString(),
      cpfCnpj: json['cpf_cnpj']?.toString(),
      email: json['email']?.toString(),
      telefone: json['telefone']?.toString(),
      dataCriacao: json['data_criacao']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'cpf_cnpj': cpfCnpj,
      'email': email,
      'telefone': telefone,
      'data_criacao': dataCriacao,
    };
  }
}
