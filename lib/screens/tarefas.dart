import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/tarefa_service.dart';
import '../theme/app_colors.dart';
import '../widgets/controle_acesso.dart';
import '../widgets/create_task_modal.dart';
import '../widgets/edit_task_modal.dart';
import '../widgets/task_card.dart';
import '../widgets/task_details_modal.dart';

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
  final _searchController = TextEditingController();
  String _searchQuery = '';

  int _selectedStatusIndex = 0; // 0: Todas, 1: Em Andamento, 2: Pendentes, 3: Concluídas
  final List<String> _statusFilters = ['Todas', 'Em Andamento', 'Pendentes', 'Concluídas'];

  TaskPriority? _selectedPriorityFilter; // null = Todas as prioridades
  bool _sortByDueDate = false; // Ordenar por prazo mais próximo

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    List<Task> list = List<Task>.from(_localTasks);

    // 1. Filtro de Status
    switch (_selectedStatusIndex) {
      case 1:
        list = list.where((t) => t.status == TaskStatus.emAndamento).toList();
        break;
      case 2:
        list = list.where((t) => t.status == TaskStatus.pendente).toList();
        break;
      case 3:
        list = list.where((t) => t.status == TaskStatus.concluido).toList();
        break;
      default:
        break;
    }

    // 2. Filtro de Prioridade
    if (_selectedPriorityFilter != null) {
      list = list.where((t) => t.priority == _selectedPriorityFilter).toList();
    }

    // 3. Filtro de Pesquisa por texto
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((t) {
        final inTitle = t.title.toLowerCase().contains(q);
        final inDesc = t.description.toLowerCase().contains(q);
        final inManager = t.managerName.toLowerCase().contains(q);
        final inClient = t.clientName != null && t.clientName!.toLowerCase().contains(q);
        return inTitle || inDesc || inManager || inClient;
      }).toList();
    }

    // 4. Ordenação
    if (_sortByDueDate) {
      list.sort((a, b) {
        final dateA = Task.parseDate(a.dueDate);
        final dateB = Task.parseDate(b.dueDate);
        return dateA.compareTo(dateB);
      });
    }

    return list;
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

  void _limparFiltros() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedStatusIndex = 0;
      _selectedPriorityFilter = null;
      _sortByDueDate = false;
    });
  }

  void _openTaskDetails(Task task) {
    final perms = UserSession.current.permissions;
    TaskDetailsModal.show(
      context: context,
      task: task,
      onStatusSelected: perms.alterarStatus
          ? (newStatus) => _handleStatusUpdate(task, newStatus)
          : null,
      onEdit: perms.editarTarefas
          ? () => _openEditTask(task)
          : null,
      onDelete: perms.excluirTarefas
          ? () => _handleDeleteTask(task)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = UserSession.current;
    final temPermissao = user.permissions.tarefas || user.isAdmin;
    final perms = user.permissions;
    final tasks = _filteredTasks;

    final filtrosAtivos = _searchQuery.isNotEmpty ||
        _selectedStatusIndex != 0 ||
        _selectedPriorityFilter != null ||
        _sortByDueDate;

    return ControleAcessoGuard(
      hasPermission: temPermissao,
      moduloNome: 'Tarefas',
      child: Scaffold(
        backgroundColor: AppColors.bgMain,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Cabeçalho
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
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

              // Barra de Pesquisa por Texto
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.bgInput,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _searchQuery.isNotEmpty ? AppColors.borderFocused : AppColors.borderSubtle,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: InputDecoration(
                      hintText: 'Buscar tarefa por título, gestor ou cliente...',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                      prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 18),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, color: Colors.white70, size: 16),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // Filtros de Status (Horizontal)
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _statusFilters.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedStatusIndex == index;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(_statusFilters[index]),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedStatusIndex = index);
                        },
                        selectedColor: Colors.white,
                        backgroundColor: AppColors.bgCard,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.bgMain : Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 11.5,
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

              const SizedBox(height: 6),

              // Barra secundária: Filtro por Prioridade e Ordenação por Prazo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // Seletor de Prioridade
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            const Text(
                              'Prioridade: ',
                              style: TextStyle(color: Colors.white54, fontSize: 11),
                            ),
                            _buildPriorityFilterChip(null, 'Todas'),
                            _buildPriorityFilterChip(TaskPriority.alta, 'Alta', TaskPriority.alta.color),
                            _buildPriorityFilterChip(TaskPriority.media, 'Média', TaskPriority.media.color),
                            _buildPriorityFilterChip(TaskPriority.baixa, 'Baixa', TaskPriority.baixa.color),
                          ],
                        ),
                      ),
                    ),

                    // Botão de Ordenar por Prazo
                    InkWell(
                      onTap: () => setState(() => _sortByDueDate = !_sortByDueDate),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _sortByDueDate ? AppColors.primaryNavy : AppColors.bgCard,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _sortByDueDate ? AppColors.borderFocused : AppColors.borderSubtle,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 11,
                              color: _sortByDueDate ? Colors.white : Colors.white60,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Prazo',
                              style: TextStyle(
                                color: _sortByDueDate ? Colors.white : Colors.white60,
                                fontSize: 10.5,
                                fontWeight: _sortByDueDate ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

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
                                          Icons.search_off_outlined,
                                          size: 48,
                                          color: Colors.white.withValues(alpha: 0.4),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          filtrosAtivos
                                              ? 'Nenhuma tarefa corresponde aos filtros aplicados'
                                              : 'Nenhuma tarefa cadastrada nesta categoria',
                                          style: const TextStyle(color: Colors.white60, fontSize: 13.5),
                                          textAlign: TextAlign.center,
                                        ),
                                        if (filtrosAtivos) ...[
                                          const SizedBox(height: 12),
                                          ElevatedButton.icon(
                                            onPressed: _limparFiltros,
                                            icon: const Icon(Icons.clear_all, size: 16, color: Colors.white),
                                            label: const Text(
                                              'Limpar Filtros e Busca',
                                              style: TextStyle(color: Colors.white, fontSize: 12),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primaryNavy,
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                side: BorderSide(color: AppColors.borderSubtle),
                                              ),
                                            ),
                                          ),
                                        ],
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
                                    onTap: () => _openTaskDetails(task),
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

  Widget _buildPriorityFilterChip(TaskPriority? priority, String label, [Color? color]) {
    final isSelected = _selectedPriorityFilter == priority;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.5),
      child: InkWell(
        onTap: () => setState(() => _selectedPriorityFilter = priority),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isSelected
                ? (color != null ? color.withValues(alpha: 0.25) : Colors.white24)
                : AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? (color ?? Colors.white)
                  : AppColors.borderSubtle,
              width: isSelected ? 1.2 : 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (color != null) ...[
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
