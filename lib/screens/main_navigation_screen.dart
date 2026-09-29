import 'package:flutter/material.dart';
import '../models/task.dart';
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
    _tasks = List.from(mockTasks);
  }

  void _onTaskCreated(Task newTask) {
    setState(() {
      _tasks.insert(0, newTask);
    });
  }

  void _onStatusUpdated(Task task, TaskStatus newStatus) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task.copyWith(status: newStatus);
      }
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status atualizado para: ${newStatus.label}'),
        backgroundColor: newStatus == TaskStatus.emAndamento
            ? const Color(0xFF1E2856)
            : newStatus == TaskStatus.pendente
                ? const Color(0xFFB45309)
                : const Color(0xFF15803D),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onTaskUpdated(Task updatedTask) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tarefa atualizada com sucesso!'),
        backgroundColor: Color(0xFF1E2856),
        duration: Duration(seconds: 2),
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
      ),
      TarefasScreen(
        tasks: _tasks,
        onTaskCreated: _onTaskCreated,
        onStatusUpdated: _onStatusUpdated,
        onTaskEdited: _onTaskUpdated,
      ),
      DesempenhoScreen(tasks: _tasks),
      const NotificacoesScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF404040),
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
                color: const Color(0xFF404040),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(
                  color: Colors.white,
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 10,
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
              color: isSelected ? Colors.white : Colors.white70,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
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
