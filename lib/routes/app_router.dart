import 'package:flutter/material.dart';
import 'package:projeto_01/screens/screens.dart';
import 'app_routes.dart';

class AppRouter {
  const AppRouter();

  Route<dynamic> generateRoute(RouteSettings settings) {
    final route = _routeFromPath(settings.name) ?? AppRoute.notFound;

    switch (route) {
      case AppRoute.home:
        return _pageRoute(const StarterScreen(), settings);
      case AppRoute.welcome:
        return _pageRoute(const WelcomeScreen(), settings);
      case AppRoute.login:
        return _pageRoute(const LoginScreen(), settings);
      case AppRoute.cadastro:
        return _pageRoute(const CadastroScreen(), settings);
      case AppRoute.dashboard:
        return _pageRoute(const DashboardScreen(), settings);
      case AppRoute.tarefas:
        return _pageRoute(const MainNavigationScreen(initialIndex: 1), settings);
      case AppRoute.desempenho:
        return _pageRoute(const MainNavigationScreen(initialIndex: 2), settings);
      case AppRoute.notificacoes:
        return _pageRoute(const MainNavigationScreen(initialIndex: 3), settings);
      case AppRoute.perfil:
        return _pageRoute(const PerfilScreen(), settings);
      case AppRoute.notFound:
        return _pageRoute(const _NotFoundPage(), settings);
    }
  }

  Route<dynamic> generateUnknownRoute(RouteSettings settings) {
    return _pageRoute(const _NotFoundPage(), settings);
  }

  AppRoute? _routeFromPath(String? path) {
    for (final route in AppRoute.values) {
      if (route.path == path) return route;
    }
    return null;
  }

  PageRoute<T> _pageRoute<T>(Widget page, RouteSettings settings) {
    return MaterialPageRoute<T>(
      settings: settings,
      builder: (_) => page,
    );
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF404040),
      body: Center(
        child: Text(
          'Página não encontrada',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
