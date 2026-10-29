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
    final manager = row.colAt(7) ?? 'LUIS FELIPPE';
    return TarefaModel(
      id: row.colAt(0) ?? '1',
      title: row.colAt(1) ?? '',
      description: row.colAt(2) ?? 'Sem descrição cadastrada.',
      status: row.colAt(3) ?? 'em_andamento',
      priority: row.colAt(4) ?? 'alta',
      dueDate: formatDateToBr(row.colAt(5)),
      timeAgo: row.colAt(6) ?? 'Agora',
      managerName: manager,
      managerInitials: initialsFromName(manager),
      isViewed: (row.colAt(8) ?? '1') == '1',
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
    };
  }
}
