import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/notificacao_service.dart';
import '../theme/app_colors.dart';
import '../widgets/controle_acesso.dart';

/// Tela de Notificações
/// Backend: GET /api/notificacoes, PUT /api/notificacoes/:id/lida,
/// PUT /api/notificacoes/lidas
class NotificacaoScreen extends StatefulWidget {
  const NotificacaoScreen({super.key});

  @override
  State<NotificacaoScreen> createState() => _NotificacaoScreenState();
}

class _NotificacaoScreenState extends State<NotificacaoScreen> {
  List<Notificacao> _notificacoes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarNotificacoes();
  }

  Future<void> _carregarNotificacoes() async {
    setState(() => _isLoading = true);
    final lista = await NotificacaoService.listarNotificacoes();
    if (!mounted) return;
    setState(() {
      _notificacoes = lista;
      _isLoading = false;
    });
  }

  Future<void> _marcarComoLida(int index) async {
    final n = _notificacoes[index];
    if (n.lida || n.id == null) return;
    final ok = await NotificacaoService.marcarComoLida(n.id!);
    if (!ok || !mounted) return;
    setState(() => _notificacoes[index] = n.copiarComoLida());
  }

  Future<void> _marcarTodasComoLidas() async {
    final ok = await NotificacaoService.marcarTodasComoLidas();
    if (!ok || !mounted) return;
    setState(() {
      _notificacoes = _notificacoes.map((n) => n.copiarComoLida()).toList();
    });
  }

  IconData _iconePorTipo(String tipo) {
    switch (tipo) {
      case 'tarefa_atribuida':
        return Icons.assignment_turned_in_outlined;
      case 'status_alterado':
        return Icons.sync;
      case 'entrevista_confirmada':
        return Icons.event_available_outlined;
      case 'feedback_solicitado':
        return Icons.rate_review_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  String _tempoRelativo(String? dataEnvio) {
    if (dataEnvio == null) return '';
    final data = DateTime.tryParse(dataEnvio.replaceFirst(' ', 'T'));
    if (data == null) return '';
    final diff = DateTime.now().difference(data);
    if (diff.inMinutes < 1) return 'Agora';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min atrás';
    if (diff.inHours < 24) {
      return diff.inHours == 1 ? '1 hora atrás' : '${diff.inHours} horas atrás';
    }
    if (diff.inDays == 1) return 'Ontem';
    if (diff.inDays < 7) return '${diff.inDays} dias atrás';
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = UserSession.current;
    final temPermissao = user.permissions.notificacoes || user.isAdmin;
    final temNaoLida = _notificacoes.any((n) => !n.lida);

    return ControleAcessoGuard(
      hasPermission: temPermissao,
      moduloNome: 'Notificações',
      child: Scaffold(
        backgroundColor: AppColors.bgMain,
        appBar: AppBar(
          backgroundColor: AppColors.bgMain,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'NOTIFICAÇÕES',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              onPressed: _carregarNotificacoes,
              tooltip: 'Atualizar',
            ),
            IconButton(
              icon: Icon(
                Icons.notifications_active_outlined,
                color: temNaoLida ? Colors.white : Colors.white30,
              ),
              onPressed: temNaoLida ? _marcarTodasComoLidas : null,
              tooltip: 'Marcar todas como lidas',
            ),
          ],
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : _notificacoes.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhuma notificação no momento',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                  itemCount: _notificacoes.length,
                  itemBuilder: (context, index) =>
                      _buildCard(_notificacoes[index], index),
                ),
        ),
      ),
    );
  }

  Widget _buildCard(Notificacao n, int index) {
    return GestureDetector(
      onTap: () => _marcarComoLida(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: n.lida ? AppColors.borderSubtle : Colors.white54,
            width: n.lida ? 1 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_iconePorTipo(n.tipo), color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n.titulo,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: n.lida
                                ? FontWeight.w600
                                : FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        _tempoRelativo(n.dataEnvio),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.mensagem,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
