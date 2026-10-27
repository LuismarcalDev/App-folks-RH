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
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    final manager = (json['managerName'] ?? 'LUIS FELIPPE').toString();
    return Task(
      id: (json['id'] ?? DateTime.now().millisecondsSinceEpoch).toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? 'Sem descrição cadastrada.').toString(),
      priority: TaskPriority.fromBackend(json['priority']?.toString()),
      dueDate: (json['dueDate'] ?? '25/08/2026').toString(),
      timeAgo: (json['timeAgo'] ?? 'Agora').toString(),
      managerName: manager,
      managerInitials: (json['managerInitials'] ?? 'L F').toString(),
      status: TaskStatus.fromBackend(json['status']?.toString()),
      isViewed: json['isViewed'] == null ? true : (json['isViewed'] == true || json['isViewed'] == 1),
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
      'userId': ?userId,
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
    managerName: 'LUIS FELIPPE',
    managerInitials: 'L F',
    status: TaskStatus.emAndamento,
    isViewed: true,
    section: 'NA ÚLTIMA SEMANA',
  ),
  const Task(
    id: '2',
    title: 'AVALIAÇÃO DE DESEMPENHO',
    description: 'Análise trimestral de metas da equipe técnica.',
    priority: TaskPriority.alta,
    dueDate: '28/08/2026',
    timeAgo: '5h',
    managerName: 'ANA BEATRIZ',
    managerInitials: 'A B',
    status: TaskStatus.emAndamento,
    isViewed: true,
    section: 'NA ÚLTIMA SEMANA',
  ),
  const Task(
    id: '3',
    title: 'TRIAGEM DE CURRÍCULOS',
    description: 'Seleção inicial para vaga de Desenvolvedor Flutter.',
    priority: TaskPriority.media,
    dueDate: '30/08/2026',
    timeAgo: '1d',
    managerName: 'LUIS FELIPPE',
    managerInitials: 'L F',
    status: TaskStatus.pendente,
    isViewed: false,
    section: 'NA ÚLTIMA SEMANA',
  ),
  const Task(
    id: '4',
    title: 'FEEDBACK ONBOARDING',
    description: 'Alinhamento com novos contratados do time comercial.',
    priority: TaskPriority.baixa,
    dueDate: '02/09/2026',
    timeAgo: '2d',
    managerName: 'CARLOS SILVA',
    managerInitials: 'C S',
    status: TaskStatus.concluido,
    isViewed: false,
    section: 'NA ÚLTIMA SEMANA',
  ),
];

/// Gerencia a lista global de tarefas em sessão (sincronizada com o MySQL quando online)
class TaskSession {
  static List<Task> tasks = List.from(mockTasks);
}

class ManagerOption {
  final String name;
  final String initials;

  const ManagerOption({required this.name, required this.initials});
}

const List<ManagerOption> availableManagers = [
  ManagerOption(name: 'LUIS FELIPPE', initials: 'L F'),
  ManagerOption(name: 'ANA BEATRIZ', initials: 'A B'),
  ManagerOption(name: 'CARLOS SILVA', initials: 'C S'),
  ManagerOption(name: 'IGOR VEIGA', initials: 'I V'),
  ManagerOption(name: 'MARIANA DIAS', initials: 'M D'),
];
