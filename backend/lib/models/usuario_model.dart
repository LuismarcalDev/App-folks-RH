import 'permissao_model.dart';

export 'permissao_model.dart';

class UsuarioModel {
  static const List<String> tiposValidos = [
    'admin',
    'gestor',
    'analista',
    'assistente',
    'auxiliar',
  ];

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
