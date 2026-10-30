import 'package:mysql_client/mysql_client.dart';

class TarefaModel {
  final String id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String dueDate;
  final String timeAgo;
  final String managerName;
  final String managerInitials;
  final bool isViewed;
  final int? userId;
  final int? clientId;
  final String? clientName;

  const TarefaModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.dueDate,
    required this.timeAgo,
    required this.managerName,
    required this.managerInitials,
    required this.isViewed,
    this.userId,
    this.clientId,
    this.clientName,
  });

  static String formatDateToBr(String? dbDate) {
    if (dbDate == null || dbDate.isEmpty) return '25/08/2026';
    if (dbDate.contains('/')) return dbDate;
    final parts = dbDate.split(' ').first.split('-');
    if (parts.length == 3) {
      return '${parts[2].padLeft(2, '0')}/${parts[1].padLeft(2, '0')}/${parts[0]}';
    }
    return dbDate;
  }

  static String formatDateToSql(String? brDate) {
    if (brDate == null || brDate.isEmpty) return '2026-08-25';
    if (brDate.contains('-')) return brDate.split(' ').first;
    final parts = brDate.split('/');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
    }
    return '2026-08-25';
  }

  static String initialsFromName(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'L F';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0].toUpperCase()} ${parts[1][0].toUpperCase()}';
  }

  factory TarefaModel.fromRow(ResultSetRow row) {
    final manager = row.colByName('Gestor_Nome') ?? row.colByName('Usuario_Nome') ?? 'LUIS FELIPPE';
    return TarefaModel(
      id: row.colByName('Id') ?? '1',
      title: row.colByName('Titulo') ?? '',
      description: row.colByName('Descricao') ?? 'Sem descrição cadastrada.',
      status: row.colByName('Status') ?? 'em_andamento',
      priority: row.colByName('Prioridade') ?? 'alta',
      dueDate: formatDateToBr(row.colByName('Data_Vencimento')),
      timeAgo: row.colByName('Data_Criacao') ?? 'Agora',
      managerName: manager,
      managerInitials: initialsFromName(manager),
      isViewed: (row.colByName('Visualizado') ?? '1') == '1',
      userId: int.tryParse(row.colByName('Usuarios_Id') ?? ''),
      clientId: int.tryParse(row.colByName('Clientes_Id') ?? ''),
      clientName: row.colByName('Cliente_Nome'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'dueDate': dueDate,
      'timeAgo': timeAgo,
      'managerName': managerName,
      'managerInitials': managerInitials,
      'isViewed': isViewed,
      'userId': userId,
      'clientId': clientId,
      'clientName': clientName,
    };
  }
}
