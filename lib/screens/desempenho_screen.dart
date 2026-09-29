import 'package:flutter/material.dart';
import '../models/task.dart';

class DesempenhoScreen extends StatelessWidget {
  final List<Task>? tasks;

  const DesempenhoScreen({super.key, this.tasks});

  @override
  Widget build(BuildContext context) {
    final allTasks = tasks ?? mockTasks;
    final total = allTasks.length;
    final emAndamento = allTasks.where((t) => t.status == TaskStatus.emAndamento).length;
    final pendentes = allTasks.where((t) => t.status == TaskStatus.pendente).length;
    final concluidas = allTasks.where((t) => t.status == TaskStatus.concluido).length;

    return Scaffold(
      backgroundColor: const Color(0xFF404040),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            // Header
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

            // Summary stats cards
            Row(
              children: [
                _buildStatCard('Total', total.toString(), const Color(0xFF1E2856)),
                const SizedBox(width: 8),
                _buildStatCard('Andamento', emAndamento.toString(), const Color(0xFF2A4365)),
                const SizedBox(width: 8),
                _buildStatCard('Pendentes', pendentes.toString(), const Color(0xFFB45309)),
                const SizedBox(width: 8),
                _buildStatCard('Concluídas', concluidas.toString(), const Color(0xFF15803D)),
              ],
            ),

            const SizedBox(height: 20),

            // Card: Distribuição de Tarefas (Donut representation)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF454545),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 1.2),
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
                      // Donut circular progress graphic
                      SizedBox(
                        width: 90,
                        height: 90,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: total > 0 ? (concluidas / total) : 0,
                              strokeWidth: 10,
                              backgroundColor: const Color(0xFF1E2856),
                              color: const Color(0xFF15803D),
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
                      // Legend
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLegendItem('Em Andamento', const Color(0xFF1E2856), emAndamento),
                            const SizedBox(height: 6),
                            _buildLegendItem('Pendente', const Color(0xFFB45309), pendentes),
                            const SizedBox(height: 6),
                            _buildLegendItem('Concluído', const Color(0xFF15803D), concluidas),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Card: Métricas e Competências (Radar placeholder)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF454545),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Competências & Entregas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Agosto 2026',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 1.0),
                      ),
                      child: Center(
                        child: Container(
                          width: 85,
                          height: 85,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white38, width: 1.0),
                            color: const Color(0xFF1E2856).withValues(alpha: 0.3),
                          ),
                          child: const Center(
                            child: Icon(Icons.radar, color: Colors.white, size: 36),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      'Eficiência da equipe em 94% este mês',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
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
          border: Border.all(color: Colors.white54, width: 1.0),
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
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }
}
