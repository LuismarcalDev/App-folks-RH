import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/tarefa_service.dart';
import '../theme/app_colors.dart';
import 'task_form_fields.dart';

class CreateTaskModal extends StatefulWidget {
  final Function(Task newTask) onTaskCreated;

  const CreateTaskModal({super.key, required this.onTaskCreated});

  @override
  State<CreateTaskModal> createState() => _CreateTaskModalState();
}

class _CreateTaskModalState extends State<CreateTaskModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  TaskPriority _selectedPriority = TaskPriority.alta;
  TaskStatus _selectedStatus = TaskStatus.emAndamento;
  DateTime _selectedDate = DateTime(2026, 8, 25);
  ManagerOption _selectedManager = availableManagers.first;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await TaskFormFields.pickTaskDate(context, _selectedDate);
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (_isLoading) return;

    if (!UserSession.current.permissions.criarTarefas) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Acesso negado: apenas pessoas que possuem permissão podem criar tarefas.',
          ),
          backgroundColor: Colors.redAccent.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final newTaskDraft = Task(
      id: '0',
      title: _titleController.text.trim().toUpperCase(),
      description: _descController.text.trim().isEmpty
          ? 'Sem descrição cadastrada.'
          : _descController.text.trim(),
      priority: _selectedPriority,
      dueDate: Task.formatDate(_selectedDate),
      timeAgo: 'Agora',
      managerName: _selectedManager.name,
      managerInitials: _selectedManager.initials,
      status: _selectedStatus,
      isViewed: true,
    );

    final created = await TarefaService.criarTarefa(newTaskDraft);
    if (!mounted) return;

    setState(() => _isLoading = false);

    if (created != null) {
      widget.onTaskCreated(created);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tarefa "${created.title}" criada com sucesso!'),
          backgroundColor: AppColors.primaryNavy,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erro ao salvar a tarefa no banco de dados.'),
          backgroundColor: Colors.redAccent.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppColors.modalSheetDecoration(),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'NOVA TAREFA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
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
              Divider(color: AppColors.borderSubtle, height: 20),
              TaskFormFields(
                titleController: _titleController,
                descController: _descController,
                selectedPriority: _selectedPriority,
                onPriorityChanged: (p) => setState(() => _selectedPriority = p),
                selectedDate: _selectedDate,
                onPickDate: _pickDate,
                managers: availableManagers,
                selectedManager: _selectedManager,
                onManagerChanged: (m) => setState(() => _selectedManager = m),
                selectedStatus: _selectedStatus,
                onStatusChanged: (s) => setState(() => _selectedStatus = s),
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: AppColors.borderStrong, width: 1.0),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'CRIAR TAREFA',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.5,
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
