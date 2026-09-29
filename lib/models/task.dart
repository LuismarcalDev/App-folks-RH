enum TaskPriority {
  alta('Alta'),
  media('Média'),
  baixa('Baixa');

  const TaskPriority(this.label);
  final String label;
}

enum TaskStatus {
  emAndamento('EM ANDAMENTO'),
  pendente('PENDENTE'),
  concluido('CONCLUÍDO');

  const TaskStatus(this.label);
  final String label;
}

class Task {
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

