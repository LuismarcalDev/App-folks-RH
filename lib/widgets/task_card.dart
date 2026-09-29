import 'package:flutter/material.dart';
import '../models/task.dart';
import 'custom_badges.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final Function(TaskStatus newStatus)? onStatusSelected;
  final VoidCallback? onStatusChanged;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const TaskCard({
    super.key,
    required this.task,
    this.onStatusSelected,
    this.onStatusChanged,
    this.onTap,
    this.onEdit,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _isExpanded = false;

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.alta:
        return const Color(0xFFE57373);
      case TaskPriority.media:
        return const Color(0xFFFFB74D);
      case TaskPriority.baixa:
        return const Color(0xFF81C784);
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.emAndamento:
        return const Color(0xFF1E2856);
      case TaskStatus.pendente:
        return const Color(0xFFB45309);
      case TaskStatus.concluido:
        return const Color(0xFF15803D);
    }
  }

  void _showStatusPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF383838),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ALTERAR STATUS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close, color: Colors.white70),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...TaskStatus.values.map((status) {
                final isCurrent = widget.task.status == status;
                final color = _getStatusColor(status);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      widget.onStatusSelected?.call(status);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isCurrent ? Colors.white : Colors.white38,
                          width: isCurrent ? 2.0 : 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            status.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          if (isCurrent)
                            const Icon(Icons.check_circle, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final priorityColor = _getPriorityColor(task.priority);
    final statusColor = _getStatusColor(task.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF454545),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 1.2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
            widget.onTap?.call();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Title and time/expand arrow
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          task.timeAgo,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        AnimatedRotation(
                          turns: _isExpanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Descrição
                const Text(
                  'Descrição',
                  style: TextStyle(
                    color: Color(0xFFBDBDBD),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  task.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 6),

                // Prioridade
                const Text(
                  'Prioridade',
                  style: TextStyle(
                    color: Color(0xFFBDBDBD),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 1),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      task.priority.label,
                      style: TextStyle(
                        color: priorityColor,
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    DoubleChevronUp(color: priorityColor, size: 14),
                  ],
                ),

                const SizedBox(height: 6),

                // Entrega
                const Text(
                  'Entrega',
                  style: TextStyle(
                    color: Color(0xFFBDBDBD),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  task.dueDate,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                if (_isExpanded) ...[
                  const SizedBox(height: 8),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 8),
                  Text(
                    'Informações adicionais da tarefa #${task.id}: Todas as etapas de validação e entrevistas técnicas estão configuradas no painel da Folks RH.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  if (widget.onEdit != null) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: widget.onEdit,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2856),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.white,
                              width: 1.0,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_outlined, color: Colors.white, size: 14),
                              SizedBox(width: 5),
                              Text(
                                'Editar Tarefa',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],

                const SizedBox(height: 10),

                // Bottom row: Manager info + Status button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Gestor
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E2856),
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.6),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              task.managerInitials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'GESTOR - ${task.managerName}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Status Button
                    InkWell(
                      onTap: () {
                        if (widget.onStatusSelected != null) {
                          _showStatusPicker();
                        } else {
                          widget.onStatusChanged?.call();
                        }
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.white,
                            width: 1.1,
                          ),
                        ),
                        child: Text(
                          task.status.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
