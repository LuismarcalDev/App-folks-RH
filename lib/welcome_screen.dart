import 'package:flutter/material.dart';
// Eu importo a tela de login para os botões abrirem a próxima etapa do fluxo.
import 'login.dart';

// Cores extraídas do design (ajuste os hex se tiver os valores exatos do Figma)
const Color kFolksNavy = Color(0xFF1B2A6B);
const Color kFolksOrange = Color(0xFFF26522);
const Color kFolksGray = Color(0xFF5C5C5C);

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // fundo escuro atrás do card
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
                  height: 90,
                  // Esta é a segunda imagem da identidade visual e permanece na welcome.
                  child: Image.asset(
                    'assets/fotos/logo2.png',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(
                  height: 180,
                  // A tag precisa ser igual à da Starter para o Hero animar esta logo.
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

                // --- TEXTO DE DESCRIÇÃO ---
                  Text(
                  'Gerencie suas tarefas e acompanhe o desempenho\nda sua equipe.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                        height: 1.4,
                      ),
                ),

                const SizedBox(height: 32),

                // O botão de login leva para a tela de autenticação.
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kFolksNavy,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Fazer login', style: TextStyle(color: Colors.white),),
                ),

                const SizedBox(height: 12),

                // Deixo este botão preparado para a futura tela de cadastro.
                ElevatedButton(
                  onPressed: () {
                    // TODO: trocar pela CadastroScreen quando ela existir
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kFolksGray,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cadastre-se',style: TextStyle(color: Colors.white),),
                ),

                const SizedBox(height: 12),
                // Por enquanto o Google usa a mesma tela; depois posso ligar a autenticação real.
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kFolksGray,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // O G funciona como uma identificação visual pequena do Google.
                      const Text(
                        'G',
                        style: TextStyle(
                          color: Color(0xFF4285F4),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
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
    );
  }
}