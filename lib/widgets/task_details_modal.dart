import 'package:flutter/material.dart';
import '../models/task_log.dart';
import '../models/user_profile.dart';
import '../services/tarefa_service.dart';
import '../theme/app_colors.dart';
import 'custom_badges.dart';

class TaskDetailsModal extends StatefulWidget {
  final Task task;
  final Function(TaskStatus newStatus)? onStatusSelected;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskDetailsModal({
    super.key,
    required this.task,
    this.onStatusSelected,
    this.onEdit,
    this.onDelete,
  });

  static Future<void> show({
    required BuildContext context,
    required Task task,
    Function(TaskStatus newStatus)? onStatusSelected,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TaskDetailsModal(
        task: task,
        onStatusSelected: onStatusSelected,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }

  @override
  State<TaskDetailsModal> createState() => _TaskDetailsModalState();
}

class _TaskDetailsModalState extends State<TaskDetailsModal> {
  late Task _currentTask;
  late Future<List<TaskLog>> _logsFuture;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
    _carregarLogs();
  }

  void _carregarLogs() {
    _logsFuture = TarefaService.buscarLogs(_currentTask.id);
  }

  Future<void> _handleStatusChange(TaskStatus newStatus) async {
    if (widget.onStatusSelected == null) return;
    final updated = await TarefaService.alterarStatusTarefa(_currentTask, newStatus);
    widget.onStatusSelected?.call(newStatus);
    if (!mounted) return;
    setState(() {
      _currentTask = updated;
      _carregarLogs();
    });
  }

  void _showStatusPicker() {
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
                      fontSize: 14,
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
                final isCurrent = status == _currentTask.status;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      _handleStatusChange(status);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? status.color.withValues(alpha: 0.85)
                            : AppColors.bgCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isCurrent ? Colors.white : AppColors.borderSubtle,
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final maxH = MediaQuery.of(context).size.height * 0.88;
    final user = UserSession.current;
    final canEdit = user.permissions.editarTarefas || user.isAdmin;
    final canDelete = user.permissions.excluirTarefas || user.isAdmin;
    final canChangeStatus = user.permissions.alterarStatus || user.isAdmin;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 680,
          maxHeight: maxH,
        ),
        child: Container(
          margin: EdgeInsets.only(bottom: bottomInset),
          decoration: BoxDecoration(
            color: AppColors.bgModal,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppColors.borderSubtle, width: 1.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 16, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderMedium),
                      ),
                      child: const Icon(
                        Icons.assignment_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'DETALHES DA TAREFA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white70),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              Divider(color: AppColors.borderSubtle, height: 1),

              // Conteúdo rolável
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Título da Tarefa
                      Text(
                        _currentTask.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Badges de Status, Prioridade e Cliente
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          // Badge de Status (clicável se puder alterar)
                          InkWell(
                            onTap: canChangeStatus ? _showStatusPicker : null,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _currentTask.status.color,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _currentTask.status.label,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                  if (canChangeStatus) ...[
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          // Badge de Prioridade
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _currentTask.priority.color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _currentTask.priority.color.withValues(alpha: 0.6),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Prioridade ${_currentTask.priority.label}',
                                  style: TextStyle(
                                    color: _currentTask.priority.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                DoubleChevronUp(color: _currentTask.priority.color, size: 13),
                              ],
                            ),
                          ),

                          // Badge de Cliente (se existir)
                          if (_currentTask.clientName != null &&
                              _currentTask.clientName!.trim().isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.business, size: 12, color: Colors.amberAccent),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Cliente: ${_currentTask.clientName}',
                                    style: const TextStyle(
                                      color: Colors.amberAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Card: Descrição Completa
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DESCRIÇÃO DA TAREFA',
                              style: TextStyle(
                                color: Color(0xFF9E9EA7),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            SelectableText(
                              _currentTask.description.isEmpty
                                  ? 'Sem descrição detalhada cadastrada.'
                                  : _currentTask.description,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Linha com Responsável e Prazo
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Responsável
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.bgCard,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.borderSubtle),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'RESPONSÁVEL',
                                    style: TextStyle(
                                      color: Color(0xFF9E9EA7),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 14,
                                        backgroundColor: AppColors.primaryNavy,
                                        child: Text(
                                          _currentTask.managerInitials,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _currentTask.managerName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Prazo de Entrega
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.bgCard,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.borderSubtle),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'DATA LIMITE / PRAZO',
                                    style: TextStyle(
                                      color: Color(0xFF9E9EA7),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_month_outlined,
                                        size: 16,
                                        color: Colors.white70,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _currentTask.dueDate,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Botões de Ações Rápidas (Editar e Excluir)
                      if (canEdit || canDelete) ...[
                        Row(
                          children: [
                            if (canEdit && widget.onEdit != null)
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    widget.onEdit?.call();
                                  },
                                  icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.white),
                                  label: const Text(
                                    'Editar Tarefa',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 11),
                                    side: BorderSide(color: AppColors.borderMedium),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                            if (canEdit && canDelete) const SizedBox(width: 10),
                            if (canDelete && widget.onDelete != null)
                              OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  widget.onDelete?.call();
                                },
                                icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                                label: const Text(
                                  'Excluir',
                                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
                                  side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: Colors.redAccent.withValues(alpha: 0.12),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Seção de Histórico / Auditoria (log_tarefa do MySQL)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.history, color: Colors.white70, size: 18),
                              const SizedBox(width: 6),
                              const Text(
                                'HISTÓRICO DA TAREFA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _carregarLogs();
                              });
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.refresh, size: 14, color: Colors.white60),
                                  SizedBox(width: 4),
                                  Text(
                                    'Atualizar',
                                    style: TextStyle(color: Colors.white60, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Timeline dos logs
                      FutureBuilder<List<TaskLog>>(
                        future: _logsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            );
                          }

                          final logs = snapshot.data ?? [];
                          if (logs.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.bgCard,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.borderSubtle),
                              ),
                              child: const Center(
                                child: Text(
                                  'Nenhum registro de log encontrado para esta tarefa.',
                                  style: TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: logs.length,
                            itemBuilder: (context, idx) {
                              final log = logs[idx];
                              final isLast = idx == logs.length - 1;

                              return IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Linha do tempo vertical com ícone
                                    SizedBox(
                                      width: 32,
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 26,
                                            height: 26,
                                            decoration: BoxDecoration(
                                              color: log.color.withValues(alpha: 0.18),
                                              shape: BoxShape.circle,
                                              border: Border.all(color: log.color, width: 1.5),
                                            ),
                                            child: Icon(log.icon, size: 14, color: log.color),
                                          ),
                                          if (!isLast)
                                            Expanded(
                                              child: Container(
                                                width: 1.5,
                                                color: Colors.white.withValues(alpha: 0.15),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),

                                    // Conteúdo do evento de log
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 9,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.bgCard,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: AppColors.borderSubtle),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  log.acaoLabel.toUpperCase(),
                                                  style: TextStyle(
                                                    color: log.color,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.4,
                                                  ),
                                                ),
                                                Text(
                                                  log.formattedDateTime,
                                                  style: const TextStyle(
                                                    color: Colors.white54,
                                                    fontSize: 10.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              log.descricao.isEmpty
                                                  ? 'Alteração realizada'
                                                  : log.descricao,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
