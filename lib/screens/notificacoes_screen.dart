import 'package:flutter/material.dart';

class NotificationItem {
  final String title;
  final String time;
  final String description;
  final IconData icon;
  final bool isUnread;

  const NotificationItem({
    required this.title,
    required this.time,
    required this.description,
    required this.icon,
    this.isUnread = false,
  });
}

class NotificacoesScreen extends StatelessWidget {
  const NotificacoesScreen({super.key});

  final List<NotificationItem> _notifications = const [
    NotificationItem(
      title: 'Nova Tarefa Atribuída',
      time: '15 min atrás',
      description: 'Luis Felippe atribuiu "ENTREVISTA - SENIOR" a você.',
      icon: Icons.assignment_turned_in,
      isUnread: true,
    ),
    NotificationItem(
      title: 'Status Alterado',
      time: '1 hora atrás',
      description: 'A tarefa "TRIAGEM DE CURRÍCULOS" mudou para EM ANDAMENTO.',
      icon: Icons.sync,
      isUnread: true,
    ),
    NotificationItem(
      title: 'Entrevista Confirmada',
      time: '3 horas atrás',
      description: 'Candidato confirmou presença para entrevista às 14:30.',
      icon: Icons.event_available,
      isUnread: false,
    ),
    NotificationItem(
      title: 'Feedback Solicitado',
      time: 'Ontem',
      description: 'Avaliação de desempenho da equipe técnica disponível.',
      icon: Icons.rate_review,
      isUnread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF404040),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'NOTIFICAÇÕES',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                Icon(Icons.notifications_active_outlined, color: Colors.white70, size: 24),
              ],
            ),
            const SizedBox(height: 16),
            ..._notifications.map((n) => _buildNotificationCard(n)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF454545),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: item.isUnread ? Colors.white : Colors.white24,
          width: item.isUnread ? 1.2 : 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2856),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white38, width: 0.8),
            ),
            child: Icon(item.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      item.time,
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
