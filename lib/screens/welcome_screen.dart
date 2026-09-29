import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

const Color kFolksNavy = Color(0xFF1B2A6B);
const Color kFolksOrange = Color(0xFFF26522);
const Color kFolksGray = Color(0xFF5C5C5C);

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              constraints: const BoxConstraints(maxWidth: 420),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 90,
                    child: Image.asset(
                      'assets/fotos/logo2.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(
                    height: 180,
                    child: Hero(
                      tag: 'folks-logo',
                      child: Image.asset(
                        'assets/fotos/logo.png',
                        height: 35,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              'ERRO AO CARREGAR LOGO\n$error',
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Gerencie suas tarefas e acompanhe o desempenho\nda sua equipe.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black87,
                          height: 1.2,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoute.login.path);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kFolksNavy,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Fazer login',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoute.cadastro.path);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kFolksGray,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cadastre-se',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoute.login.path);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kFolksGray,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'G',
                          style: TextStyle(
                            color: Color(0xFF4285F4),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Login com Google',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
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
