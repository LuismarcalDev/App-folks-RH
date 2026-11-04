import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import 'task_form_fields.dart';

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

  List<ClientOption> _clients = [];
  ClientOption? _selectedClient;

  bool _isLoading = false;

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
    _selectedDate = Task.parseDate(widget.task.dueDate);

    _managers = List.from(availableManagers);
    final matchIndex = _managers.indexWhere(
      (m) =>
          (widget.task.userId != null && m.id == widget.task.userId) ||
          m.name.trim().toUpperCase() == widget.task.managerName.trim().toUpperCase(),
    );

    if (matchIndex != -1) {
      _selectedManager = _managers[matchIndex];
    } else {
      final customManager = ManagerOption(
        id: widget.task.userId,
        name: widget.task.managerName,
        initials: widget.task.managerInitials,
      );
      _managers.add(customManager);
      _selectedManager = customManager;
    }

    if (widget.task.clientId != null || widget.task.clientName != null) {
      _selectedClient = ClientOption(
        id: widget.task.clientId,
        name: widget.task.clientName ?? 'Cliente #${widget.task.clientId}',
      );
    }

    _carregarDadosReais();
  }

  Future<void> _carregarDadosReais() async {
    try {
      final futures = await Future.wait([
        ApiService.listarFuncionarios(),
        ApiService.listarClientes(),
      ]);

      final funcs = futures[0] as List<UserProfile>;
      final clis = futures[1] as List<Cliente>;

      if (mounted) {
        setState(() {
          if (funcs.isNotEmpty) {
            _managers = funcs.map((u) {
              return ManagerOption(
                id: u.id,
                name: u.name,
                initials: Task.initialsFromName(u.name),
                role: u.role,
              );
            }).toList();

            final matchIndex = _managers.indexWhere(
              (m) =>
                  (widget.task.userId != null && m.id == widget.task.userId) ||
                  m.name.trim().toUpperCase() == widget.task.managerName.trim().toUpperCase(),
            );

            if (matchIndex != -1) {
              _selectedManager = _managers[matchIndex];
            } else if (_managers.isNotEmpty) {
              final custom = ManagerOption(
                id: widget.task.userId,
                name: widget.task.managerName,
                initials: widget.task.managerInitials,
              );
              _managers.insert(0, custom);
              _selectedManager = custom;
            }
          }

          if (clis.isNotEmpty) {
            _clients = clis.map((c) => ClientOption(id: c.id, name: c.nome)).toList();
            if (widget.task.clientId != null) {
              final matchCli = _clients.firstWhere(
                (c) => c.id == widget.task.clientId,
                orElse: () => ClientOption(
                  id: widget.task.clientId,
                  name: widget.task.clientName ?? 'Cliente #${widget.task.clientId}',
                ),
              );
              _selectedClient = matchCli;
            }
          }
        });
      }
    } catch (_) {}
  }

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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updatedTask = widget.task.copyWith(
      title: _titleController.text.trim().toUpperCase(),
      description: _descController.text.trim().isEmpty
          ? 'Sem descrição cadastrada.'
          : _descController.text.trim(),
      priority: _selectedPriority,
      dueDate: Task.formatDate(_selectedDate),
      userId: _selectedManager.id,
      managerName: _selectedManager.name,
      managerInitials: _selectedManager.initials,
      clientId: _selectedClient?.id,
      clientName: _selectedClient?.name,
      status: _selectedStatus,
    );

    final saved = await TarefaService.editarTarefa(updatedTask);
    if (!mounted) return;

    setState(() => _isLoading = false);

    widget.onTaskSaved(saved);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tarefa "${saved.title}" atualizada com sucesso!'),
        backgroundColor: AppColors.primaryNavy,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
              Divider(color: AppColors.borderSubtle, height: 20),
              TaskFormFields(
                titleController: _titleController,
                descController: _descController,
                selectedPriority: _selectedPriority,
                onPriorityChanged: (p) => setState(() => _selectedPriority = p),
                selectedDate: _selectedDate,
                onPickDate: _pickDate,
                managers: _managers,
                selectedManager: _selectedManager,
                onManagerChanged: (m) => setState(() => _selectedManager = m),
                clients: _clients,
                selectedClient: _selectedClient,
                onClientChanged: (c) => setState(() => _selectedClient = c),
                selectedStatus: _selectedStatus,
                onStatusChanged: (s) => setState(() => _selectedStatus = s),
              ),
              const SizedBox(height: 22),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon: _isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check, color: Colors.white, size: 18),
                label: Text(
                  _isLoading ? 'SALVANDO...' : 'SALVAR ALTERAÇÕES',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: AppColors.borderStrong, width: 1.0),
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
