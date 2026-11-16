import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_01/models/notificacao.dart';
import 'package:projeto_01/models/task.dart';

void main() {
  group('Notificacao model', () {
    test('fromJson e toJson preservam tipo e campos principais', () {
      final notif = Notificacao.fromJson({
        'id': 7,
        'usuario_id': 2,
        'titulo': 'Nova Tarefa Atribuída',
        'mensagem': 'Luis atribuiu "Entrevista" a você.',
        'lida': 0,
        'data_envio': '2026-11-16 12:00:00',
        'tipo': 'tarefa_atribuida',
      });

      expect(notif.id, 7);
      expect(notif.usuarioId, 2);
      expect(notif.lida, isFalse);
      expect(notif.tipo, 'tarefa_atribuida');
      expect(notif.toJson()['tipo'], 'tarefa_atribuida');

      final lida = notif.copiarComoLida();
      expect(lida.lida, isTrue);
      expect(lida.tipo, 'tarefa_atribuida');
    });
  });

  group('Task model', () {
    test('toJson preserva userId do responsável atribuído', () {
      const task = Task(
        id: '10',
        title: 'ENTREVISTA',
        description: 'Descrição teste',
        priority: TaskPriority.alta,
        dueDate: '20/11/2026',
        timeAgo: 'Agora',
        managerName: 'Igor Veiga',
        managerInitials: 'I V',
        status: TaskStatus.emAndamento,
        userId: 2,
        clientId: 1,
        clientName: 'Google Brasil',
      );

      final json = task.toJson();
      expect(json['userId'], 2);
      expect(json['clientId'], 1);
      expect(json['status'], 'em_andamento');
    });
  });
}
