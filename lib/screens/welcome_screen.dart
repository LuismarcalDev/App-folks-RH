
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Center(
                child: Container(
                  height: constraints.maxHeight - 45,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  constraints: const BoxConstraints(maxWidth: 420),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logos na parte superior
                      Transform.translate(
                        offset: const Offset(0, -73),
                        child: Column(
                          children: [
                            // Logo laranja
                            SizedBox(
                              height: 180,
                              child: Center(
                                child: Transform.scale(
                                  scale: 0.65,
                                  child: Image.asset(
                                    'assets/fotos/logo.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),

                            // Logo nome Folks
                            SizedBox(
                              height: 90,
                              child: Transform.translate(
                                offset: const Offset(0, -35),
                                child: Image.asset(
                                  'assets/fotos/logo2.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Texto e botões na parte inferior
                      Transform.translate(
                        offset: const Offset(0, -15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Gerencie suas tarefas e acompanhe o desempenho\nda sua equipe.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.black87,
                                    height: 1.2,
                                  ),
                            ),

                            const SizedBox(height: 16),

                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pushNamed(AppRoute.login.path);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kFolksNavy,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
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
                                Navigator.of(context)
                                    .pushNamed(AppRoute.cadastro.path);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kFolksGray,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Cadastre-se',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
