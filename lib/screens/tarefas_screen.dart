import 'package:flutter/material.dart';
import '../models/task.dart';
import '../widgets/create_task_modal.dart';
import '../widgets/edit_task_modal.dart';
import '../widgets/task_card.dart';

class TarefasScreen extends StatefulWidget {
  final List<Task>? tasks;
  final Function(Task newTask)? onTaskCreated;
  final Function(Task task, TaskStatus newStatus)? onStatusUpdated;
  final Function(Task updatedTask)? onTaskEdited;

  const TarefasScreen({
    super.key,
    this.tasks,
    this.onTaskCreated,
    this.onStatusUpdated,
    this.onTaskEdited,
  });

  @override
  State<TarefasScreen> createState() => _TarefasScreenState();
}

class _TarefasScreenState extends State<TarefasScreen> {
  int _selectedFilterIndex = 0; // 0: Todas, 1: Em Andamento, 2: Pendentes, 3: Concluídas

  final List<String> _filters = ['Todas', 'Em Andamento', 'Pendentes', 'Concluídas'];

  List<Task> get _currentTasks => widget.tasks ?? mockTasks;

  List<Task> get _filteredTasks {
    final all = _currentTasks;
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

  void _openCreateTask() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreateTaskModal(
        onTaskCreated: (newTask) {
          widget.onTaskCreated?.call(newTask);
          setState(() {});
        },
      ),
    );
  }

  void _openEditTask(Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditTaskModal(
        task: task,
        onTaskSaved: (updatedTask) {
          widget.onTaskEdited?.call(updatedTask);
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _filteredTasks;

    return Scaffold(
      backgroundColor: const Color(0xFF404040),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  InkWell(
                    onTap: _openCreateTask,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2856),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 1.0),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 18),
                          SizedBox(width: 4),
                          Text(
                            'Nova Tarefa',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal Filter Chips
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
                      backgroundColor: const Color(0xFF4A4A4A),
                      labelStyle: TextStyle(
                        color: isSelected ? const Color(0xFF333333) : Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isSelected ? Colors.white : Colors.white24,
                        ),
                      ),
                      showCheckmark: false,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Task list
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.task_alt, size: 48, color: Colors.white.withValues(alpha: 0.4)),
                          const SizedBox(height: 12),
                          Text(
                            'Nenhuma tarefa nesta categoria',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return TaskCard(
                          task: task,
                          onStatusSelected: (newStatus) {
                            widget.onStatusUpdated?.call(task, newStatus);
                            setState(() {});
                          },
                          onEdit: () => _openEditTask(task),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
