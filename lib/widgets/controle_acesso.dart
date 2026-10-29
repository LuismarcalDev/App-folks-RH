import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../theme/app_colors.dart';

/// Widget de proteção que valida permissão no sistema antes de exibir a tela
class ControleAcessoGuard extends StatelessWidget {
  final bool hasPermission;
  final String moduloNome;
  final Widget child;

  const ControleAcessoGuard({
    super.key,
    required this.hasPermission,
    required this.moduloNome,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (hasPermission) {
      return child;
    }

    final user = UserSession.current;

    return Scaffold(
      backgroundColor: AppColors.bgMain,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle, width: 1.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade900.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_person_outlined,
                      color: Colors.amberAccent,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'ACESSO RESTRITO - $moduloNome',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Olá, ${user.name} (${user.tipo.toUpperCase()}).\n'
                    'Sua conta não possui permissão ativa para acessar o módulo de $moduloNome no sistema.\n\n'
                    'Para obter acesso, solicite a um Administrador a liberação no painel de permissões.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
