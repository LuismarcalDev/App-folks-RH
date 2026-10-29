import 'package:mysql_client/mysql_client.dart';
import 'permissao_model.dart';

class FuncaoModel {
  final int id;
  final String nome;
  final String tipo;
  final String departamento;
  final PermissoesUsuario permissoes;

  const FuncaoModel({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.departamento,
    required this.permissoes,
  });

  factory FuncaoModel.fromRow(ResultSetRow row) {
    final tipo = (row.colAt(2) ?? 'assistente').toLowerCase().trim();
    final padrao = PermissoesUsuario.padraoPorTipo(tipo);
    return FuncaoModel(
      id: int.tryParse(row.colAt(0) ?? '') ?? 1,
      nome: row.colAt(1) ?? '',
      tipo: tipo,
      departamento: row.colAt(3) ?? 'Folks RH - Recrutamento & Seleção',
      permissoes: PermissoesUsuario(
        criarTarefas: PermissoesUsuario.parseBool(row.colAt(4), padrao.criarTarefas),
        editarTarefas: PermissoesUsuario.parseBool(row.colAt(5), padrao.editarTarefas),
        excluirTarefas: PermissoesUsuario.parseBool(row.colAt(6), padrao.excluirTarefas),
        alterarStatus: PermissoesUsuario.parseBool(row.colAt(7), padrao.alterarStatus),
        verDesempenho: PermissoesUsuario.parseBool(row.colAt(8), padrao.verDesempenho),
        gerenciarPermissoes: PermissoesUsuario.parseBool(row.colAt(9), padrao.gerenciarPermissoes),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo,
      'departamento': departamento,
      'permissoes': permissoes.toJson(),
    };
  }
}
