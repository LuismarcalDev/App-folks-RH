import 'package:flutter/material.dart';
import 'inicio.dart';

export 'inicio.dart';

class MainNavigationScreen extends StatelessWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return InicioScreen(initialIndex: initialIndex);
  }
}
