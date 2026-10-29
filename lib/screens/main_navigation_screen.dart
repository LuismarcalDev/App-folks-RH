import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';
import 'desempenho_screen.dart';
import 'notificacoes_screen.dart';
import 'tarefas_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  late List<Task> _tasks;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _tasks = List.from(TaskSession.tasks);
    _loadTasksFromBackend();
  }

  Future<void> _loadTasksFromBackend() async {
    final loaded = await ApiService.listarTarefas();
    if (!mounted) return;
    setState(() {
      _tasks = List.from(loaded);
    });
  }

  Future<void> _onTaskCreated(Task newTask) async {
    if (!UserSession.current.permissions.criarTarefas) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
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

    final created = await ApiService.criarTarefa(newTask);
    if (!mounted || created == null) return;

    setState(() {
      _tasks = List.from(TaskSession.tasks);
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tarefa "${created.title}" criada com sucesso!'),
        backgroundColor: const Color(0xFF15803D),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _onStatusUpdated(Task task, TaskStatus newStatus) async {
    await ApiService.alterarStatusTarefa(task, newStatus);
    if (!mounted) return;

    setState(() {
      _tasks = List.from(TaskSession.tasks);
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status alterado para: ${newStatus.label}'),
        backgroundColor: newStatus.color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _onTaskUpdated(Task updatedTask) async {
    await ApiService.editarTarefa(updatedTask);
    if (!mounted) return;

    setState(() {
      _tasks = List.from(TaskSession.tasks);
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tarefa editada e alterada com sucesso!'),
        backgroundColor: Color(0xFF1E2856),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _onTaskDeleted(Task task) async {
    await ApiService.excluirTarefa(task);
    if (!mounted) return;

    setState(() {
      _tasks = List.from(TaskSession.tasks);
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tarefa "${task.title}" excluída com sucesso!'),
        backgroundColor: Colors.redAccent.shade700,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardContent(
        tasks: _tasks,
        onTaskCreated: _onTaskCreated,
        onStatusUpdated: _onStatusUpdated,
        onTaskEdited: _onTaskUpdated,
        onTaskDeleted: _onTaskDeleted,
        onPermissionsUpdated: () => setState(() {}),
      ),
      TarefasScreen(
        tasks: _tasks,
        onTaskCreated: _onTaskCreated,
        onStatusUpdated: _onStatusUpdated,
        onTaskEdited: _onTaskUpdated,
        onTaskDeleted: _onTaskDeleted,
      ),
      DesempenhoScreen(tasks: _tasks),
      const NotificacoesScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF18181C),
      body: Stack(
        children: [
          // IndexedStack preserves the scroll position and state of all tabs
          IndexedStack(
            index: _currentIndex,
            children: screens,
          ),

          // Shared Floating Bottom Navigation Bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF222228),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.16),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    index: 0,
                    icon: Icons.home_outlined,
                    label: 'Início',
                  ),
                  _buildNavItem(
                    index: 1,
                    icon: Icons.assignment_outlined,
                    label: 'Tarefas',
                  ),
                  _buildNavItem(
                    index: 2,
                    icon: Icons.pie_chart_outline_rounded,
                    label: 'Desempenho',
                  ),
                  _buildNavItem(
                    index: 3,
                    icon: Icons.notifications_none_outlined,
                    label: 'Notificação',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white60,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
