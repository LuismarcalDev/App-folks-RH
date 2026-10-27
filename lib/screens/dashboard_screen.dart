import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/user_profile.dart';
import '../routes/app_routes.dart';
import '../widgets/create_task_modal.dart';
import '../widgets/custom_badges.dart';
import '../widgets/edit_task_modal.dart';
import '../widgets/permissions_management_modal.dart';
import '../widgets/task_card.dart';
import 'main_navigation_screen.dart';

/// Entrypoint para rota /dashboard
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainNavigationScreen(initialIndex: 0);
  }
}

/// Conteúdo da aba Início / Dashboard
class DashboardContent extends StatefulWidget {
  final List<Task> tasks;
  final Function(Task newTask)? onTaskCreated;
  final Function(Task task, TaskStatus newStatus)? onStatusUpdated;
  final Function(Task updatedTask)? onTaskEdited;
  final Function(Task task)? onTaskDeleted;
  final VoidCallback? onPermissionsUpdated;

  const DashboardContent({
    super.key,
    required this.tasks,
    this.onTaskCreated,
    this.onStatusUpdated,
    this.onTaskEdited,
    this.onTaskDeleted,
    this.onPermissionsUpdated,
  });

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  int _selectedTab = 0; // 0 = Visualizado, 1 = Novas Tarefas
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Task> get _filteredTasks {
    return widget.tasks.where((task) {
      final matchesTab = _selectedTab == 0 ? task.isViewed : !task.isViewed;
      final matchesSearch = _searchQuery.isEmpty ||
          task.title.toLowerCase().contains(_searchQuery) ||
          task.description.toLowerCase().contains(_searchQuery) ||
          task.managerName.toLowerCase().contains(_searchQuery);

      return matchesTab && matchesSearch;
    }).toList();
  }

  void _showPermissionDenied(String acao) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Acesso negado: seu nível (${UserSession.current.tipo.toUpperCase()}) não possui permissão para $acao.',
        ),
        backgroundColor: Colors.redAccent.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showNewTaskDialog() {
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
          widget.onTaskEdited?.call(updatedTask);
        },
      ),
    );
  }

  void _openPermissionsPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PermissionsManagementModal(
        onPermissionsChanged: () {
          if (mounted) setState(() {});
          widget.onPermissionsUpdated?.call();
        },
      ),
    );
  }

  Future<void> _showProfileOptions() async {
    await Navigator.of(context).pushNamed(AppRoute.perfil.path);
    if (mounted) {
      setState(() {});
      widget.onPermissionsUpdated?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _filteredTasks;
    final perms = UserSession.current.permissions;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          // --- TOP HEADER ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Profile Pill Container
              Flexible(
                child: InkWell(
                  onTap: _showProfileOptions,
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(4, 4, 14, 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF404040),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ProfileAvatar(
                          size: 32,
                          icon: UserSession.current.isAdmin
                              ? Icons.admin_panel_settings_outlined
                              : Icons.person,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            UserSession.current.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: UserSession.current.isAdmin
                                ? Colors.amber.shade800
                                : const Color(0xFF1E2856),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white54, width: 0.8),
                          ),
                          child: Text(
                            UserSession.current.tipo.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (perms.gerenciarPermissoes) ...[
                    Tooltip(
                      message: 'Gerenciar Permissões (MySQL)',
                      child: InkWell(
                        onTap: _openPermissionsPanel,
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: const Color(0xFF1E2856),
                            border: Border.all(
                              color: Colors.amberAccent,
                              width: 1.2,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.admin_panel_settings,
                                color: Colors.amberAccent,
                                size: 20,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Permissões',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Plus Button (+)
                  InkWell(
                    onTap: _showNewTaskDialog,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: perms.criarTarefas
                            ? const Color(0xFF404040)
                            : const Color(0xFF333333),
                        border: Border.all(
                          color: perms.criarTarefas ? Colors.white : Colors.white38,
                          width: 1.2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          perms.criarTarefas ? Icons.add : Icons.lock_outline,
                          color: perms.criarTarefas ? Colors.white : Colors.white54,
                          size: perms.criarTarefas ? 26 : 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // --- SEARCH BAR ---
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF404040),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white,
                width: 1.2,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    cursorColor: Colors.white,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: '',
                    ),
                  ),
                ),
                const Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // --- SEGMENTED TAB SWITCHER (Visualizado / Novas Tarefas) ---
          Container(
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF404040),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white,
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                // Visualizado tab
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: _selectedTab == 0 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Visualizado',
                        style: TextStyle(
                          color: _selectedTab == 0 ? const Color(0xFF333333) : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                // Novas Tarefas tab
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Container(
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: _selectedTab == 1 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Novas Tarefas',
                        style: TextStyle(
                          color: _selectedTab == 1 ? const Color(0xFF333333) : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- SECTION TITLE: NA ÚLTIMA SEMANA ---
          Row(
            children: [
              const Text(
                'NA ÚLTIMA SEMANA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.public,
                color: Colors.white.withValues(alpha: 0.9),
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.9),
          ),

          const SizedBox(height: 16),

          // --- TASK CARDS LIST ---
          if (tasks.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 36),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 48,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'Nenhuma tarefa encontrada para "$_searchQuery"'
                        : _selectedTab == 0
                            ? 'Nenhuma tarefa visualizada'
                            : 'Nenhuma nova tarefa no momento',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            )
          else
            ...tasks.map((task) => TaskCard(
                  task: task,
                  onStatusSelected: perms.alterarStatus
                      ? (newStatus) => widget.onStatusUpdated?.call(task, newStatus)
                      : null,
                  onStatusChanged: perms.alterarStatus
                      ? null
                      : () => _showPermissionDenied('alterar o status de tarefas'),
                  onEdit: perms.editarTarefas ? () => _openEditTask(task) : null,
                  onDelete: perms.excluirTarefas
                      ? () => widget.onTaskDeleted?.call(task)
                      : null,
                )),
        ],
      ),
    );
  }
}
