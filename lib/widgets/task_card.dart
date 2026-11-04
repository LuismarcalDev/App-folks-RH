import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme/app_colors.dart';
import 'custom_badges.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Function(TaskStatus newStatus)? onStatusSelected;
  final VoidCallback? onStatusChanged;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    this.onStatusSelected,
    this.onStatusChanged,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  void _confirmDelete(BuildContext context) {
    if (onDelete == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgModal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
        title: const Text(
          'Excluir Tarefa',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Tem certeza que deseja excluir a tarefa "${task.title}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onDelete?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'EXCLUIR',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgModal,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: AppColors.borderSubtle, width: 1.0),
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
                    'ALTERAR STATUS DA TAREFA',
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
                final isCurrent = task.status == status;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      onStatusSelected?.call(status);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: status.color,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isCurrent ? AppColors.borderFocused : AppColors.borderSubtle,
                          width: isCurrent ? 1.5 : 1.0,
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
    final priorityColor = task.priority.color;
    final statusColor = task.status.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 12,
                          ),
                        ),
                        if (onTap != null) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right, size: 16, color: Colors.white54),
                        ],
                      ],
                    ),
                  ],
                ),
          const SizedBox(height: 6),
          const Text(
            'Descrição',
            style: TextStyle(color: Color(0xFF9E9EA7), fontSize: 10.5),
          ),
          const SizedBox(height: 1),
          Text(
            task.description,
            style: const TextStyle(color: Colors.white, fontSize: 12.5, height: 1.2),
          ),
          if (task.clientName != null && task.clientName!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.35)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.business_outlined, size: 12, color: Colors.amberAccent),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Cliente: ${task.clientName}',
                      style: const TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Prioridade',
                    style: TextStyle(color: Color(0xFF9E9EA7), fontSize: 10.5),
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
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Entrega',
                    style: TextStyle(color: Color(0xFF9E9EA7), fontSize: 10.5),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    task.dueDate,
                    style: const TextStyle(color: Colors.white, fontSize: 12.5),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.white.withValues(alpha: 0.10), height: 1),
          const SizedBox(height: 8),
          if (onEdit != null || onDelete != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onEdit != null)
                  InkWell(
                    onTap: onEdit,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.borderMedium),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_outlined, color: Colors.white, size: 13),
                          SizedBox(width: 4),
                          Text(
                            'Editar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (onEdit != null && onDelete != null) const SizedBox(width: 8),
                if (onDelete != null)
                  InkWell(
                    onTap: () => _confirmDelete(context),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.shade700,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.borderMedium),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete_outline, color: Colors.white, size: 13),
                          SizedBox(width: 4),
                          Text(
                            'Excluir',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.borderMedium, width: 0.8),
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
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  if (onStatusSelected != null) {
                    _showStatusPicker(context);
                  } else {
                    onStatusChanged?.call();
                  }
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.borderStrong, width: 1.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        task.status.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.sync_alt, color: Colors.white, size: 13),
                    ],
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
