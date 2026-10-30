import 'package:flutter/material.dart';

class TaskLog {
  final int id;
  final int tarefasId;
  final String acao;
  final String descricao;
  final DateTime dataCriacao;

  const TaskLog({
    required this.id,
    required this.tarefasId,
    required this.acao,
    required this.descricao,
    required this.dataCriacao,
  });

  factory TaskLog.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      final raw = json['dataCriacao']?.toString() ?? '';
      parsedDate = DateTime.tryParse(raw) ?? DateTime.now();
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return TaskLog(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      tarefasId: json['tarefasId'] is int
          ? json['tarefasId'] as int
          : int.tryParse(json['tarefasId']?.toString() ?? '0') ?? 0,
      acao: (json['acao'] ?? 'atualizada').toString().toLowerCase().trim(),
      descricao: (json['descricao'] ?? '').toString().trim(),
      dataCriacao: parsedDate,
    );
  }

  String get acaoLabel {
    switch (acao) {
      case 'criada':
        return 'Criação';
      case 'concluida':
        return 'Conclusão';
      case 'cancelada':
        return 'Cancelamento';
      case 'reativada':
        return 'Reativação';
      case 'atualizada':
      default:
        return 'Atualização';
    }
  }

  IconData get icon {
    switch (acao) {
      case 'criada':
        return Icons.add_task;
      case 'concluida':
        return Icons.check_circle_outline;
      case 'cancelada':
        return Icons.cancel_outlined;
      case 'reativada':
        return Icons.restart_alt;
      case 'atualizada':
      default:
        return Icons.edit_note_outlined;
    }
  }

  Color get color {
    switch (acao) {
      case 'criada':
        return const Color(0xFF60A5FA); // Azul
      case 'concluida':
        return const Color(0xFF4ADE80); // Verde
      case 'cancelada':
        return const Color(0xFFF87171); // Vermelho
      case 'reativada':
        return const Color(0xFFA78BFA); // Roxo
      case 'atualizada':
      default:
        return const Color(0xFFFBBF24); // Âmbar
    }
  }

  String get formattedDateTime {
    final day = dataCriacao.day.toString().padLeft(2, '0');
    final month = dataCriacao.month.toString().padLeft(2, '0');
    final year = dataCriacao.year;
    final hour = dataCriacao.hour.toString().padLeft(2, '0');
    final min = dataCriacao.minute.toString().padLeft(2, '0');
    return '$day/$month/$year às $hour:$min';
  }
}
