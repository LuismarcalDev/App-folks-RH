import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class StarterScreen extends StatefulWidget {
  const StarterScreen({super.key});

  @override
  State<StarterScreen> createState() => _StarterScreenState();
}

class _StarterScreenState extends State<StarterScreen> {
  @override
  void initState() {
    super.initState();
    // Tempo da animação da logo antes de ir para a tela de boas-vindas
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoute.welcome.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Alias para manter compatibilidade
typedef Starter = StarterScreen;
