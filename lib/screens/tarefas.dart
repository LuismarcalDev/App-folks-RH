import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/tarefa_service.dart';
import '../theme/app_colors.dart';
import '../widgets/controle_acesso.dart';
import '../widgets/create_task_modal.dart';
import '../widgets/edit_task_modal.dart';
import '../widgets/task_card.dart';

/// Tela de Tarefas — Totalmente conectada com a API e banco MySQL
class TarefasScreen extends StatefulWidget {
  final List<Task>? tasks;
  final Function(Task newTask)? onTaskCreated;
  final Function(Task task, TaskStatus newStatus)? onStatusUpdated;
  final Function(Task updatedTask)? onTaskEdited;
  final Function(Task task)? onTaskDeleted;

  const TarefasScreen({
    super.key,
    this.tasks,
    this.onTaskCreated,
    this.onStatusUpdated,
    this.onTaskEdited,
    this.onTaskDeleted,
  });

  @override
  State<TarefasScreen> createState() => _TarefasScreenState();
}

class _TarefasScreenState extends State<TarefasScreen> {
  int _selectedFilterIndex = 0; // 0: Todas, 1: Em Andamento, 2: Pendentes, 3: Concluídas
  final List<String> _filters = ['Todas', 'Em Andamento', 'Pendentes', 'Concluídas'];

  bool _isLoading = false;
  late List<Task> _localTasks;

  @override
  void initState() {
    super.initState();
    _localTasks = widget.tasks != null
        ? List<Task>.from(widget.tasks!)
        : List<Task>.from(TaskSession.tasks);

    _carregarTarefasDoBanco();
  }

  @override
  void didUpdateWidget(covariant TarefasScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tasks != null) {
      _localTasks = List<Task>.from(widget.tasks!);
    }
  }

  Future<void> _carregarTarefasDoBanco() async {
    setState(() => _isLoading = true);
    final loaded = await TarefaService.listarTarefas();
    if (!mounted) return;
    setState(() {
      _localTasks = List<Task>.from(loaded);
      _isLoading = false;
    });
  }

  List<Task> get _filteredTasks {
    final all = _localTasks;
    switch (_selectedFilterIndex) {
      case 1:
        return all.where((t) => t.status == TaskStatus.emAndamento).toList();
      case 2:
        return all.where((t) => t.status == TaskStatus.pendente).toList();
      case 3:
        return all.where((t) => t.status == TaskStatus.concluido).toList();
      default:
        return all;
    }
  }

  void _showPermissionDenied(String acao) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Acesso negado: sua conta não possui permissão para $acao.'),
        backgroundColor: Colors.redAccent.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openCreateTask() {
    if (!UserSession.current.permissions.criarTarefas) {
      _showPermissionDenied('criar novas tarefas');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreateTaskModal(
        onTaskCreated: (newTask) {
          setState(() {
            _localTasks.removeWhere((t) => t.id == newTask.id);
            _localTasks.insert(0, newTask);
          });
          widget.onTaskCreated?.call(newTask);
        },
      ),
    );
  }

  void _openEditTask(Task task) {
    if (!UserSession.current.permissions.editarTarefas) {
      _showPermissionDenied('editar tarefas');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditTaskModal(
        task: task,
        onTaskSaved: (updatedTask) {
          setState(() {
            final idx = _localTasks.indexWhere((t) => t.id == updatedTask.id);
            if (idx != -1) {
              _localTasks[idx] = updatedTask;
            }
          });
          widget.onTaskEdited?.call(updatedTask);
        },
      ),
    );
  }

  Future<void> _handleStatusUpdate(Task task, TaskStatus newStatus) async {
    if (!UserSession.current.permissions.alterarStatus) {
      _showPermissionDenied('alterar status');
      return;
    }

    final updated = await TarefaService.alterarStatusTarefa(task, newStatus);
    if (!mounted) return;

    setState(() {
      final idx = _localTasks.indexWhere((t) => t.id == task.id);
      if (idx != -1) {
        _localTasks[idx] = updated;
      }
    });

    widget.onStatusUpdated?.call(task, newStatus);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status de "${task.title}" alterado para ${newStatus.label}'),
        backgroundColor: newStatus.color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleDeleteTask(Task task) async {
    if (!UserSession.current.permissions.excluirTarefas) {
      _showPermissionDenied('excluir tarefas');
      return;
    }

    final success = await TarefaService.excluirTarefa(task);
    if (!mounted) return;

    if (success) {
      setState(() {
        _localTasks.removeWhere((t) => t.id == task.id);
      });
      widget.onTaskDeleted?.call(task);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tarefa "${task.title}" excluída com sucesso.'),
          backgroundColor: AppColors.primaryNavy,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erro ao excluir tarefa do banco.'),
          backgroundColor: Colors.redAccent.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = UserSession.current;
    final temPermissao = user.permissions.tarefas || user.isAdmin;
    final perms = user.permissions;
    final tasks = _filteredTasks;

    return ControleAcessoGuard(
      hasPermission: temPermissao,
      moduloNome: 'Tarefas',
      child: Scaffold(
        backgroundColor: AppColors.bgMain,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'TAREFAS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _carregarTarefasDoBanco,
                          tooltip: 'Atualizar do Banco de Dados',
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white70,
                                  ),
                                )
                              : const Icon(Icons.refresh, color: Colors.white70, size: 18),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: _openCreateTask,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: perms.criarTarefas ? AppColors.primaryNavy : AppColors.bgCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: perms.criarTarefas ? AppColors.borderStrong : AppColors.borderSubtle,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              perms.criarTarefas ? Icons.add : Icons.lock_outline,
                              color: perms.criarTarefas ? Colors.white : Colors.white54,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Nova Tarefa',
                              style: TextStyle(
                                color: perms.criarTarefas ? Colors.white : Colors.white54,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Filtros horizontais
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedFilterIndex == index;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(_filters[index]),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedFilterIndex = index);
                        },
                        selectedColor: Colors.white,
                        backgroundColor: AppColors.bgCard,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.bgMain : Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isSelected ? AppColors.borderFocused : AppColors.borderSubtle,
                          ),
                        ),
                        showCheckmark: false,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Lista de Tarefas com Pull-to-refresh
              Expanded(
                child: _isLoading && _localTasks.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : RefreshIndicator(
                        onRefresh: _carregarTarefasDoBanco,
                        color: Colors.white,
                        backgroundColor: AppColors.primaryNavy,
                        child: tasks.isEmpty
                            ? ListView(
                                padding: const EdgeInsets.only(top: 60),
                                children: [
                                  Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.task_alt,
                                          size: 48,
                                          color: Colors.white.withValues(alpha: 0.4),
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'Nenhuma tarefa nesta categoria',
                                          style: TextStyle(color: Colors.white60, fontSize: 14),
                                        ),
                                        const SizedBox(height: 8),
                                        TextButton.icon(
                                          onPressed: _carregarTarefasDoBanco,
                                          icon: const Icon(Icons.refresh, size: 16, color: Colors.white70),
                                          label: const Text(
                                            'Recarregar do banco',
                                            style: TextStyle(color: Colors.white70),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                                itemCount: tasks.length,
                                itemBuilder: (context, index) {
                                  final task = tasks[index];
                                  return TaskCard(
                                    task: task,
                                    onStatusSelected: perms.alterarStatus
                                        ? (newStatus) => _handleStatusUpdate(task, newStatus)
                                        : null,
                                    onStatusChanged: perms.alterarStatus
                                        ? null
                                        : () => _showPermissionDenied('alterar status'),
                                    onEdit: perms.editarTarefas
                                        ? () => _openEditTask(task)
                                        : () => _showPermissionDenied('editar tarefas'),
                                    onDelete: perms.excluirTarefas
                                        ? () => _handleDeleteTask(task)
                                        : () => _showPermissionDenied('excluir tarefas'),
                                  );
                                },
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
