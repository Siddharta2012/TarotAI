// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'providers/application_providers.dart';
import 'screens/home_page.dart';
import 'screens/login_screen.dart';
import 'screens/initialization_screen.dart'; // 1. Importa la nuova schermata

// La funzione main ora è molto semplice. Non esegue inizializzazioni.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Avvolgiamo tutto in ProviderScope come prima
  runApp(const ProviderScope(child: AppLauncher()));
}

/// Questo widget decide quale schermata mostrare all'avvio.
class AppLauncher extends StatelessWidget {
  const AppLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: InitializationScreen(), // 2. La prima schermata è quella di caricamento
    );
  }
}

/// Questo è il cuore della nostra applicazione, che prima era in main.dart
class TarotApp extends StatelessWidget {
  const TarotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tarocchi AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData( // Il tema rimane qui
        brightness: Brightness.dark,
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF2C2A4A),
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurple,
          secondary: Colors.deepPurpleAccent,
          surface: Color(0xFF4F4C7A),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white70,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Inter', color: Colors.white),
          bodyMedium: TextStyle(fontFamily: 'Inter', color: Colors.white70),
          headlineSmall: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF4F4C7A),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: const Color(0xFF4F4C7A),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: const Color(0xFF2C2A4A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

/// L'AuthWrapper rimane invariato, gestisce la logica post-login
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const HomePage();
        }
        return const LoginScreen();
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => const Scaffold(body: Center(child: Text('Qualcosa è andato storto.'))),
    );
  }
}