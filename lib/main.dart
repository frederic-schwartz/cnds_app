import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/directus_service.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final directusService = DirectusService();

    return ChangeNotifierProvider(
      create: (_) => AuthProvider(directusService),
      child: MaterialApp(
        title: 'CNDS App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
