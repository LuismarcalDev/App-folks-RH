import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../theme/app_colors.dart';

class DesempenhoScreen extends StatelessWidget {
  final List<Task>? tasks;

  const DesempenhoScreen({super.key, this.tasks});

  @override
  Widget build(BuildContext context) {
    final perms = UserSession.current.permissions;

    if (!perms.verDesempenho) {
      return Scaffold(
        backgroundColor: AppColors.bgMain,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_person_outlined, color: Colors.amberAccent, size: 52),
                    const SizedBox(height: 14),
                    const Text(
                      'ACESSO RESTRITO AOS INDICADORES',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Olá, ${UserSession.current.name} (${UserSession.current.tipo.toUpperCase()}).\n'
                      'Sua conta não possui a permissão para visualizar métricas de desempenho.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final allTasks = tasks ?? TaskSession.tasks;
    final total = allTasks.length;
    final emAndamento = allTasks.where((t) => t.status == TaskStatus.emAndamento).length;
    final pendentes = allTasks.where((t) => t.status == TaskStatus.pendente).length;
    final concluidas = allTasks.where((t) => t.status == TaskStatus.concluido).length;

    return Scaffold(
      backgroundColor: AppColors.bgMain,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'DESEMPENHO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                Icon(Icons.insights, color: Colors.white70, size: 24),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard('Total', total.toString(), AppColors.primaryNavy),
                const SizedBox(width: 8),
                _buildStatCard('Andamento', emAndamento.toString(), const Color(0xFF2A4365)),
                const SizedBox(width: 8),
                _buildStatCard('Pendentes', pendentes.toString(), AppColors.warningAmber),
                const SizedBox(width: 8),
                _buildStatCard('Concluídas', concluidas.toString(), AppColors.successGreen),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle, width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Distribuição por Status',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(
                        width: 90,
                        height: 90,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: total > 0 ? (concluidas / total) : 0,
                              strokeWidth: 10,
                              backgroundColor: AppColors.primaryNavy,
                              color: AppColors.successGreen,
                            ),
                            Text(
                              total > 0 ? '${((concluidas / total) * 100).toInt()}%' : '0%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLegendItem('Em Andamento', AppColors.primaryNavy, emAndamento),
                            const SizedBox(height: 6),
                            _buildLegendItem('Pendente', AppColors.warningAmber, pendentes),
                            const SizedBox(height: 6),
                            _buildLegendItem('Concluído', AppColors.successGreen, concluidas),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderMedium, width: 1.0),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
        Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
