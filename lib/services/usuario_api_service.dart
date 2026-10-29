import '../models/user_profile.dart';
import 'auth_service.dart';
import 'funcionario_service.dart';

/// Adaptador legado para manter retrocompatibilidade com código existente
class UsuarioApiService {
  static Future<UserProfile?> login(String login, String senha) =>
      AuthService.login(login, senha);

  static Future<List<UserProfile>> listarUsuarios() =>
      FuncionarioService.listarFuncionarios();

  static Future<UserProfile?> salvarPermissoes({
    required int userId,
    required String tipo,
    required UserPermissions permissions,
  }) =>
      FuncionarioService.salvarPermissoes(
        funcionarioId: userId,
        tipo: tipo,
        permissions: permissions,
      );

  static Future<UserProfile?> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
    String tipo = 'assistente',
    String? funcaoNome,
    String? departamento,
    String? codigoUtilizado,
    UserPermissions? permissions,
  }) =>
      AuthService.cadastrar(
        nome: nome,
        email: email,
        senha: senha,
        tipo: tipo,
        funcaoNome: funcaoNome,
        departamento: departamento,
        codigoUtilizado: codigoUtilizado,
        permissions: permissions,
      );
}
