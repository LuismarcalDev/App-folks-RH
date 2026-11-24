import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class StarterScreen extends StatefulWidget {
  const StarterScreen({super.key});

  @override
  State<StarterScreen> createState() => _StarterScreenState();
}

class _StarterScreenState extends State<StarterScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  late Animation<double> _logoPosition;
  late Animation<double> _textOpacity;
  late Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    );

    // A logo fica parada no centro e depois sobe.
    _logoPosition = Tween<double>(
      begin: 0,
      end: -235,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.65,
          1.00,
          curve: Curves.easeInOutCubic,
        ),
      ),
    );

    // Nome, texto e botões aparecem juntos.
    _textOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.28,
          0.40,
          curve: Curves.easeIn,
        ),
      ),
    );

    // A logo cresce, fica parada e diminui enquanto sobe.
    _logoScale = TweenSequence<double>([
      // Crescimento inicial
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.15,
          end: 1.0,
        ).chain(
          CurveTween(curve: Curves.easeOutCubic),
        ),
        weight: 25,
      ),

      // Pausa no centro
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 40,
      ),

      // Diminui enquanto sobe
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.65,
        ).chain(
          CurveTween(curve: Curves.easeInOutCubic),
        ),
        weight: 35,
      ),
    ]).animate(_controller);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward();
      }
    });

    // Aguarda a animação terminar antes de abrir a WelcomeScreen.
    _controller.addStatusListener((status){
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(context).pushReplacementNamed(
          AppRoute.welcome.path,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Mantém os logos nas mesmas posições da WelcomeScreen.
                          Transform.translate(
                            offset: const Offset(0, -73),
                            child: SizedBox(
                              height: 270,
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 180,
                                    left: 0,
                                    right: 0,
                                    height: 90,
                                    child: Opacity(
                                      opacity: _textOpacity.value,
                                      child: Transform.translate(
                                        offset: const Offset(0, -35),
                                        child: Image.asset(
                                          'assets/fotos/logo2.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Pintada por último para ficar à frente da logo2.
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    height: 180,
                                    child: Transform.translate(
                                      // Compensa o deslocamento animado para que,
                                      // ao terminar, a logo fique na posição final.
                                      offset: Offset(0, 235 + _logoPosition.value),
                                      child: Transform.scale(
                                        scale: _logoScale.value,
                                        child: Image.asset(
                                          'assets/fotos/logo.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Opacity(
                            opacity: _textOpacity.value,
                            child: Transform.translate(
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
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1B2A6B),
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
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF5C5C5C),
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
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
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
