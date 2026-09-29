import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/user_profile.dart';
import '../routes/app_routes.dart';
import '../widgets/create_task_modal.dart';
import '../widgets/custom_badges.dart';
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

  const DashboardContent({
    super.key,
    required this.tasks,
    this.onTaskCreated,
    this.onStatusUpdated,
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

  void _showNewTaskDialog() {
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

  Future<void> _showProfileOptions() async {
    await Navigator.of(context).pushNamed(AppRoute.perfil.path);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _filteredTasks;

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
              InkWell(
                onTap: _showProfileOptions,
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
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
                        icon: UserSession.current.avatarChoice == AvatarChoice.admin
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
                    ],
                  ),
                ),
              ),

              // Plus Button (+)
              InkWell(
                onTap: _showNewTaskDialog,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF404040),
                    border: Border.all(
                      color: Colors.white,
                      width: 1.2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
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
                  onStatusSelected: (newStatus) => widget.onStatusUpdated?.call(task, newStatus),
                )),
        ],
      ),
    );
  }
}
