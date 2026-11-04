import 'package:flutter/material.dart';

enum TaskPriority {
  alta('Alta', Color(0xFFE57373), 'alta'),
  media('Média', Color(0xFFFFB74D), 'media'),
  baixa('Baixa', Color(0xFF81C784), 'baixa');

  const TaskPriority(this.label, this.color, this.backendKey);
  final String label;
  final Color color;
  final String backendKey;

  static TaskPriority fromBackend(String? val) {
    switch (val?.toLowerCase().trim()) {
      case 'alta':
        return TaskPriority.alta;
      case 'baixa':
        return TaskPriority.baixa;
      case 'media':
      default:
        return TaskPriority.media;
    }
  }
}

enum TaskStatus {
  emAndamento('EM ANDAMENTO', Color(0xFF1E2856), 'em_andamento'),
  pendente('PENDENTE', Color(0xFFB45309), 'pendente'),
  concluido('CONCLUÍDO', Color(0xFF15803D), 'concluida');

  const TaskStatus(this.label, this.color, this.backendKey);
  final String label;
  final Color color;
  final String backendKey;

  static TaskStatus fromBackend(String? val) {
    switch (val?.toLowerCase().trim()) {
      case 'pendente':
        return TaskStatus.pendente;
      case 'concluida':
      case 'concluido':
        return TaskStatus.concluido;
      case 'em_andamento':
      default:
        return TaskStatus.emAndamento;
    }
  }
}

class Task {
  static String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  static DateTime parseDate(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      }
    } catch (_) {}
    return DateTime.now();
  }

  static String initialsFromName(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'RH';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0].toUpperCase()} ${parts[1][0].toUpperCase()}';
  }

  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final String dueDate;
  final String timeAgo;
  final String managerName;
  final String managerInitials;
  final TaskStatus status;
  final bool isViewed;
  final String section;
  final int? userId;
  final int? clientId;
  final String? clientName;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    required this.timeAgo,
    required this.managerName,
    required this.managerInitials,
    required this.status,
    this.isViewed = true,
    this.section = 'NA ÚLTIMA SEMANA',
    this.userId,
    this.clientId,
    this.clientName,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    final manager = (json['managerName'] ?? 'Admin Folks').toString();
    return Task(
      id: (json['id'] ?? DateTime.now().millisecondsSinceEpoch).toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? 'Sem descrição cadastrada.').toString(),
      priority: TaskPriority.fromBackend(json['priority']?.toString()),
      dueDate: (json['dueDate'] ?? '25/08/2026').toString(),
      timeAgo: (json['timeAgo'] ?? 'Agora').toString(),
      managerName: manager,
      managerInitials: (json['managerInitials'] ?? initialsFromName(manager)).toString(),
      status: TaskStatus.fromBackend(json['status']?.toString()),
      isViewed: json['isViewed'] == null ? true : (json['isViewed'] == true || json['isViewed'] == 1),
      userId: json['userId'] is int ? json['userId'] as int : int.tryParse(json['userId']?.toString() ?? ''),
      clientId: json['clientId'] is int ? json['clientId'] as int : int.tryParse(json['clientId']?.toString() ?? ''),
      clientName: json['clientName']?.toString(),
    );
  }

  Map<String, dynamic> toJson({int? userId}) {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.backendKey,
      'dueDate': dueDate,
      'timeAgo': timeAgo,
      'managerName': managerName,
      'managerInitials': managerInitials,
      'status': status.backendKey,
      'isViewed': isViewed,
      'userId': userId ?? this.userId,
      'clientId': clientId,
      'clientName': clientName,
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskPriority? priority,
    String? dueDate,
    String? timeAgo,
    String? managerName,
    String? managerInitials,
    TaskStatus? status,
    bool? isViewed,
    String? section,
    int? userId,
    int? clientId,
    String? clientName,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      timeAgo: timeAgo ?? this.timeAgo,
      managerName: managerName ?? this.managerName,
      managerInitials: managerInitials ?? this.managerInitials,
      status: status ?? this.status,
      isViewed: isViewed ?? this.isViewed,
      section: section ?? this.section,
      userId: userId ?? this.userId,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
    );
  }
}

final List<Task> mockTasks = [
  const Task(
    id: '1',
    title: 'ENTREVISTA - SENIOR',
    description: 'Cargo de auxiliar de administrador senior.',
    priority: TaskPriority.alta,
    dueDate: '25/08/2026',
    timeAgo: '2h',
    managerName: 'Admin Folks',
    managerInitials: 'A F',
    status: TaskStatus.emAndamento,
    isViewed: true,
    section: 'NA ÚLTIMA SEMANA',
  ),
];

/// Gerencia a lista global de tarefas em sessão (sincronizada com o MySQL quando online)
class TaskSession {
  static List<Task> tasks = List.from(mockTasks);
}

class ManagerOption {
  final int? id;
  final String name;
  final String initials;
  final String? role;

  const ManagerOption({
    this.id,
    required this.name,
    required this.initials,
    this.role,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ManagerOption &&
          runtimeType == other.runtimeType &&
          ((id != null && id == other.id) || name.toUpperCase().trim() == other.name.toUpperCase().trim());

  @override
  int get hashCode => (id ?? name.toUpperCase().trim()).hashCode;
}

class ClientOption {
  final int? id;
  final String name;

  const ClientOption({this.id, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientOption &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const List<ManagerOption> availableManagers = [
  ManagerOption(id: 1, name: 'Admin Folks', initials: 'A F', role: 'Gestor de RH'),
  ManagerOption(name: 'LUIS FELIPPE', initials: 'L F', role: 'Gestor de RH'),
  ManagerOption(name: 'ANA BEATRIZ', initials: 'A B', role: 'Analista de RH'),
  ManagerOption(name: 'CARLOS SILVA', initials: 'C S', role: 'Assistente de RH'),
];
