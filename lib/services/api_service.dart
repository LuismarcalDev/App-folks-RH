import '../models/user_profile.dart';
import 'auth_service.dart';
import 'cliente_service.dart';
import 'funcao_api_service.dart';
import 'funcionario_service.dart';
import 'notificacao_service.dart';
import 'tarefa_service.dart';

export 'auth_service.dart';
export 'cliente_service.dart';
export 'funcao_api_service.dart';
export 'funcionario_service.dart';
export 'notificacao_service.dart';
export 'tarefa_service.dart';

/// Fachada unificada dos serviços da API Folks RH
class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8081';

  // --- Autenticação & Usuários ---
  static Future<UserProfile?> login(String login, String senha) =>
      AuthService.login(login, senha);

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

  // --- Funcionários & Permissões ---
  static Future<List<UserProfile>> listarUsuarios() =>
      FuncionarioService.listarFuncionarios();

  static Future<List<UserProfile>> listarFuncionarios() =>
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

  // --- Funções (Cargos) ---
  static Future<List<JobFunction>> listarFuncoes() =>
      FuncaoApiService.listarFuncoes();

  static Future<JobFunction> cadastrarFuncao({
    required String nome,
    required String tipo,
    required String departamento,
    required UserPermissions permissions,
  }) =>
      FuncaoApiService.cadastrarFuncao(
        nome: nome,
        tipo: tipo,
        departamento: departamento,
        permissions: permissions,
      );

  static Future<bool> excluirFuncao(int id) =>
      FuncaoApiService.excluirFuncao(id);

  // --- Tarefas ---
  static Future<List<Task>> listarTarefas() =>
      TarefaService.listarTarefas();

  static Future<Task?> criarTarefa(Task newTask) =>
      TarefaService.criarTarefa(newTask);

  static Future<Task> editarTarefa(Task updatedTask) =>
      TarefaService.editarTarefa(updatedTask);

  static Future<Task> alterarStatusTarefa(Task task, TaskStatus newStatus) =>
      TarefaService.alterarStatusTarefa(task, newStatus);

  static Future<bool> excluirTarefa(Task task) =>
      TarefaService.excluirTarefa(task);

  // --- Clientes ---
  static Future<List<Cliente>> listarClientes() =>
      ClienteService.listarClientes();

  static Future<Cliente?> cadastrarCliente({
    required String nome,
    String? cpfCnpj,
    String? email,
    String? telefone,
  }) =>
      ClienteService.cadastrarCliente(
        nome: nome,
        cpfCnpj: cpfCnpj,
        email: email,
        telefone: telefone,
      );

  // --- Notificações ---
  static Future<List<Notificacao>> listarNotificacoes() =>
      NotificacaoService.listarNotificacoes();

  static Future<Notificacao?> enviarNotificacao({
    required String titulo,
    required String mensagem,
    int? usuarioId,
  }) =>
      NotificacaoService.enviarNotificacao(
        titulo: titulo,
        mensagem: mensagem,
        usuarioId: usuarioId,
      );
}
