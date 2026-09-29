import 'package:flutter/material.dart';
import 'package:projeto_01/routes/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: const AppRouter().generateRoute,
      onUnknownRoute: const AppRouter().generateUnknownRoute,
    );
  }
}
