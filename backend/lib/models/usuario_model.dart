class UsuarioModel {
  final int? id;
  final String nome;
  final String tipo;
  final int? setorId;
  final String email;
  final String? telefone;
  final String? senha;
  final int? codigoAutenticacaoId;
  final String? codigoUtilizado;

  UsuarioModel({
    this.id,
    required this.nome,
    required this.tipo,
    this.setorId,
    required this.email,
    this.telefone,
    this.senha,
    this.codigoAutenticacaoId,
    this.codigoUtilizado,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    final tiposValidos = ['gestor', 'analista', 'assistente', 'auxiliar'];
    final tipoInformado = json['tipo']?.toString().toLowerCase();

    if (json['nome'] == null || json['nome'].toString().trim().isEmpty) {
      throw ArgumentError('O campo "nome" é obrigatório.');
    }
    if (json['email'] == null || json['email'].toString().trim().isEmpty) {
      throw ArgumentError('O campo "email" é obrigatório.');
    }
    if (json['senha'] == null || json['senha'].toString().trim().isEmpty) {
      throw ArgumentError('O campo "senha" é obrigatório.');
    }
    if (tipoInformado == null || !tiposValidos.contains(tipoInformado)) {
      throw ArgumentError('O tipo deve ser: gestor, analista, assistente ou auxiliar.');
    }

    return UsuarioModel(
      id: json['id'] as int?,
      nome: json['nome'] as String,
      tipo: tipoInformado,
      setorId: json['setor_id'] as int?,
      email: json['email'] as String,
      telefone: json['telefone'] as String?,
      senha: json['senha'] as String?,
      codigoAutenticacaoId: json['codigo_autenticacao_id'] as int?,
      codigoUtilizado: json['codigo_utilizado'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo,
      'setor_id': setorId,
      'email': email,
      'telefone': telefone,
      'codigo_autenticacao_id': codigoAutenticacaoId,
      'codigo_utilizado': codigoUtilizado,
    };
  }
}
