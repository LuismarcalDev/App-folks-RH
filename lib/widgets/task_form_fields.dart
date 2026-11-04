import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme/app_colors.dart';
import 'custom_badges.dart';

class TaskFormFields extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descController;
  final TaskPriority selectedPriority;
  final ValueChanged<TaskPriority> onPriorityChanged;
  final DateTime selectedDate;
  final VoidCallback onPickDate;
  final List<ManagerOption> managers;
  final ManagerOption selectedManager;
  final ValueChanged<ManagerOption> onManagerChanged;
  final TaskStatus selectedStatus;
  final ValueChanged<TaskStatus> onStatusChanged;
  final List<ClientOption>? clients;
  final ClientOption? selectedClient;
  final ValueChanged<ClientOption?>? onClientChanged;

  const TaskFormFields({
    super.key,
    required this.titleController,
    required this.descController,
    required this.selectedPriority,
    required this.onPriorityChanged,
    required this.selectedDate,
    required this.onPickDate,
    required this.managers,
    required this.selectedManager,
    required this.onManagerChanged,
    required this.selectedStatus,
    required this.onStatusChanged,
    this.clients,
    this.selectedClient,
    this.onClientChanged,
  });

  static Future<DateTime?> pickTaskDate(BuildContext context, DateTime initialDate) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryNavy,
              onPrimary: Colors.white,
              surface: AppColors.bgModal,
              onSurface: Colors.white,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: AppColors.bgModal,
              shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                side: BorderSide(color: AppColors.borderSubtle),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Título da Tarefa *',
          style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: titleController,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          validator: (val) =>
              (val == null || val.trim().isEmpty) ? 'Informe o título da tarefa' : null,
          decoration: AppColors.darkInputDecoration(hintText: 'ex: ENTREVISTA - PLENO'),
        ),
        const SizedBox(height: 14),
        const Text(
          'Descrição',
          style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: descController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: AppColors.darkInputDecoration(
            hintText: 'Descreva os detalhes da tarefa ou vaga...',
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Prioridade',
          style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Row(
          children: TaskPriority.values.map((priority) {
            final isSelected = selectedPriority == priority;
            final color = priority.color;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: InkWell(
                  onTap: () => onPriorityChanged(priority),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withValues(alpha: 0.25) : AppColors.bgInput,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? color : AppColors.borderSubtle,
                        width: isSelected ? 1.4 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          priority.label,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                        if (priority == TaskPriority.alta) ...[
                          const SizedBox(width: 4),
                          DoubleChevronUp(color: isSelected ? color : Colors.white54, size: 12),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Entrega',
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: onPickDate,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.bgInput,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            Task.formatDate(selectedDate),
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                          const Icon(Icons.calendar_month, color: Colors.white70, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Responsável',
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.bgInput,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ManagerOption>(
                        value: selectedManager,
                        isExpanded: true,
                        dropdownColor: AppColors.bgInput,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                        items: managers.map((mgr) {
                          return DropdownMenuItem<ManagerOption>(
                            value: mgr,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mgr.name,
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (mgr.role != null && mgr.role!.isNotEmpty)
                                  Text(
                                    mgr.role!,
                                    style: const TextStyle(color: Colors.white54, fontSize: 9.5),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) onManagerChanged(val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (clients != null && onClientChanged != null) ...[
          const SizedBox(height: 14),
          const Text(
            'Cliente Associado (Opcional)',
            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ClientOption?>(
                value: selectedClient,
                isExpanded: true,
                dropdownColor: AppColors.bgInput,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                items: [
                  const DropdownMenuItem<ClientOption?>(
                    value: null,
                    child: Text(
                      'Nenhum cliente (Interno / Geral)',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ),
                  ...clients!.map((cli) {
                    return DropdownMenuItem<ClientOption?>(
                      value: cli,
                      child: Text(
                        cli.name,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                ],
                onChanged: onClientChanged,
              ),
            ),
          ),
        ],
        const SizedBox(height: 14),
        const Text(
          'Status da Tarefa',
          style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Row(
          children: TaskStatus.values.map((status) {
            final isSelected = selectedStatus == status;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: InkWell(
                  onTap: () => onStatusChanged(status),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? status.color : AppColors.bgInput,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.borderFocused : AppColors.borderSubtle,
                        width: isSelected ? 1.3 : 1.0,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      status.label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
