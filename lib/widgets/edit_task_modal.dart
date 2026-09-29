import 'package:flutter/material.dart';
import '../models/task.dart';
import 'custom_badges.dart';

class EditTaskModal extends StatefulWidget {
  final Task task;
  final Function(Task updatedTask) onTaskSaved;

  const EditTaskModal({
    super.key,
    required this.task,
    required this.onTaskSaved,
  });

  @override
  State<EditTaskModal> createState() => _EditTaskModalState();
}

class _EditTaskModalState extends State<EditTaskModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;

  late TaskPriority _selectedPriority;
  late TaskStatus _selectedStatus;
  late DateTime _selectedDate;
  late List<ManagerOption> _managers;
  late ManagerOption _selectedManager;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(
      text: widget.task.description == 'Sem descrição cadastrada.'
          ? ''
          : widget.task.description,
    );

    _selectedPriority = widget.task.priority;
    _selectedStatus = widget.task.status;
    _selectedDate = _parseDate(widget.task.dueDate);

    _managers = List.from(availableManagers);
    final matchIndex = _managers.indexWhere(
      (m) => m.name.trim().toUpperCase() == widget.task.managerName.trim().toUpperCase(),
    );

    if (matchIndex != -1) {
      _selectedManager = _managers[matchIndex];
    } else {
      final customManager = ManagerOption(
        name: widget.task.managerName,
        initials: widget.task.managerInitials,
      );
      _managers.add(customManager);
      _selectedManager = customManager;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  DateTime _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (_) {}
    return DateTime.now();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF1E2856),
              onPrimary: Colors.white,
              surface: Color(0xFF383838),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF383838),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                side: BorderSide(color: Colors.white24),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final updatedTask = widget.task.copyWith(
      title: _titleController.text.trim().toUpperCase(),
      description: _descController.text.trim().isEmpty
          ? 'Sem descrição cadastrada.'
          : _descController.text.trim(),
      priority: _selectedPriority,
      dueDate: _formatDate(_selectedDate),
      managerName: _selectedManager.name,
      managerInitials: _selectedManager.initials,
      status: _selectedStatus,
    );

    widget.onTaskSaved(updatedTask);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF383838),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with title and close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.edit_note, color: Colors.white, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'EDITAR TAREFA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: 20),

              // Title Field
              const Text(
                'Título da Tarefa *',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Informe o título da tarefa';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'ex: ENTREVISTA - PLENO',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF454545),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white70, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white54, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white, width: 1.2),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Description Field
              const Text(
                'Descrição',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Descreva os detalhes da tarefa ou vaga...',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF454545),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white70, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white54, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white, width: 1.2),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Priority Selector
              const Text(
                'Prioridade',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: TaskPriority.values.map((priority) {
                  final isSelected = _selectedPriority == priority;
                  Color color;
                  switch (priority) {
                    case TaskPriority.alta:
                      color = const Color(0xFFE57373);
                      break;
                    case TaskPriority.media:
                      color = const Color(0xFFFFB74D);
                      break;
                    case TaskPriority.baixa:
                      color = const Color(0xFF81C784);
                      break;
                  }

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: InkWell(
                        onTap: () => setState(() => _selectedPriority = priority),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? color.withValues(alpha: 0.25) : const Color(0xFF454545),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? color : Colors.white24,
                              width: isSelected ? 1.5 : 1.0,
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

              // Row for Due Date & Manager
              Row(
                children: [
                  // Data de Entrega
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Entrega',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF454545),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white54, width: 1.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDate(_selectedDate),
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

                  // Gestor Responsável
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gestor',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF454545),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white54, width: 1.0),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<ManagerOption>(
                              value: _selectedManager,
                              isExpanded: true,
                              dropdownColor: const Color(0xFF454545),
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                              icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                              items: _managers.map((mgr) {
                                return DropdownMenuItem<ManagerOption>(
                                  value: mgr,
                                  child: Text(
                                    mgr.name,
                                    style: const TextStyle(color: Colors.white, fontSize: 11),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedManager = val);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Status Selector
              const Text(
                'Status da Tarefa',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: TaskStatus.values.map((status) {
                  final isSelected = _selectedStatus == status;
                  Color statusBg;
                  switch (status) {
                    case TaskStatus.emAndamento:
                      statusBg = const Color(0xFF1E2856);
                      break;
                    case TaskStatus.pendente:
                      statusBg = const Color(0xFFB45309);
                      break;
                    case TaskStatus.concluido:
                      statusBg = const Color(0xFF15803D);
                      break;
                  }

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: InkWell(
                        onTap: () => setState(() => _selectedStatus = status),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? statusBg : const Color(0xFF454545),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.white24,
                              width: isSelected ? 1.4 : 1.0,
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

              const SizedBox(height: 22),

              // Save Changes Button
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check, color: Colors.white, size: 18),
                label: const Text(
                  'SALVAR ALTERAÇÕES',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E2856),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.white, width: 1.2),
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
