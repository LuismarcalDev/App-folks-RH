import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../routes/app_routes.dart';
import '../services/tarefa_service.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_badges.dart';
import 'clientes.dart';
import 'funcionarios.dart';
import 'notificacao.dart';
import 'tarefas.dart';

class InicioScreen extends StatefulWidget {
  final int initialIndex;

  const InicioScreen({super.key, this.initialIndex = 0});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  late int _currentIndex;
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _tasks = List.from(TaskSession.tasks);
    _carregarTarefas();
  }

  Future<void> _carregarTarefas() async {
    final loaded = await TarefaService.listarTarefas();
    if (!mounted) return;
    setState(() {
      _tasks = List.from(loaded);
    });
  }

  void _abrirFuncionarios() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FuncionariosScreen()),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _abrirPerfil() {
    Navigator.of(context).pushNamed(AppRoute.perfil.path).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = UserSession.current;
    final perms = user.permissions;

    final screens = [
      _buildDashboardTab(user, perms),
      TarefasScreen(
        tasks: _tasks,
        onTaskCreated: (newTask) {
          setState(() {
            _tasks.removeWhere((t) => t.id == newTask.id);
            _tasks.insert(0, newTask);
          });
        },
        onStatusUpdated: (task, newStatus) {
          setState(() {
            final idx = _tasks.indexWhere((t) => t.id == task.id);
            if (idx != -1) {
              _tasks[idx] = _tasks[idx].copyWith(status: newStatus);
            }
          });
        },
        onTaskEdited: (updatedTask) {
          setState(() {
            final idx = _tasks.indexWhere((t) => t.id == updatedTask.id);
            if (idx != -1) {
              _tasks[idx] = updatedTask;
            }
          });
        },
        onTaskDeleted: (task) {
          setState(() {
            _tasks.removeWhere((t) => t.id == task.id);
          });
        },
      ),
      const ClientesScreen(),
      const NotificacaoScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.bgMain,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: screens,
          ),

          // Barra inferior flutuante
          Positioned(
            left: 20,
            right: 20,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.bgNav,
                borderRadius: BorderRadius.circular(36),
                border: Border.all(color: AppColors.borderMedium),
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
                  _buildNavItem(0, Icons.home_outlined, 'Início'),
                  _buildNavItem(1, Icons.assignment_outlined, 'Tarefas'),
                  _buildNavItem(2, Icons.people_outline, 'Clientes'),
                  _buildNavItem(3, Icons.notifications_none_outlined, 'Notificações'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab(UserProfile user, UserPermissions perms) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          // Header com Avatar e Nível
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: InkWell(
                  onTap: _abrirPerfil,
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(4, 4, 14, 4),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.borderMedium),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ProfileAvatar(
                          size: 32,
                          icon: user.isAdmin ? Icons.admin_panel_settings_outlined : Icons.person,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            user.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: user.isAdmin ? Colors.amber.shade800 : AppColors.primaryNavy,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            user.tipo.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (perms.funcionarios || user.isAdmin)
                Tooltip(
                  message: 'Gerenciar Funcionários',
                  child: InkWell(
                    onTap: _abrirFuncionarios,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.45)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.admin_panel_settings, color: Colors.amberAccent, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Funcionários',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          // Card de Boas-vindas
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, ${user.name}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${user.role} • ${user.department}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Módulos com acesso liberado para você:',
                  style: TextStyle(color: Colors.white60, fontSize: 11.5),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildModuleBadge('Clientes', perms.clientes, () => setState(() => _currentIndex = 2)),
                    _buildModuleBadge('Tarefas', perms.tarefas, () => setState(() => _currentIndex = 1)),
                    _buildModuleBadge('Notificações', perms.notificacoes, () => setState(() => _currentIndex = 3)),
                    if (perms.funcionarios)
                      _buildModuleBadge('Funcionários', true, _abrirFuncionarios),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Atalhos rápidos
          const Text(
            'NAVEGAÇÃO RÁPIDA',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  title: 'Tarefas',
                  icon: Icons.assignment_outlined,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickAction(
                  title: 'Clientes',
                  icon: Icons.people_outline,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickAction(
                  title: 'Notificações',
                  icon: Icons.notifications_none,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleBadge(String name, bool enabled, VoidCallback onTap) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: enabled ? AppColors.primaryNavy : Colors.white10,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled ? Colors.greenAccent.withValues(alpha: 0.4) : Colors.white12,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              enabled ? Icons.check_circle_outline : Icons.lock_outline,
              size: 13,
              color: enabled ? Colors.greenAccent : Colors.white38,
            ),
            const SizedBox(width: 4),
            Text(
              name,
              style: TextStyle(
                color: enabled ? Colors.white : Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.white60, size: 22),
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
