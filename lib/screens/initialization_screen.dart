// lib/screens/initialization_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart'; // 1. IMPORTA IL PACCHETTO GIUSTO
import '../firebase_options.dart';
import '../main.dart'; 

class InitializationScreen extends StatefulWidget {
  const InitializationScreen({super.key});

  @override
  State<InitializationScreen> createState() => _InitializationScreenState();
}

class _InitializationScreenState extends State<InitializationScreen> {
  String _loadingMessage = 'Avvio in corso...';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Step 1: Inizializzazione della localizzazione (LA NOSTRA CORREZIONE)
      setState(() {
        _loadingMessage = 'Preparazione ambiente...';
      });
      // 2. Aggiungi questa riga per caricare i dati della lingua italiana
      await initializeDateFormatting('it_IT', null);

      // Step 2: Caricamento delle configurazioni
      setState(() {
        _loadingMessage = 'Caricamento configurazioni...';
      });
      await dotenv.load(fileName: ".env");
      
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 3: Inizializzazione di Firebase
      setState(() {
        _loadingMessage = 'Connessione ai servizi...';
      });
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      await Future.delayed(const Duration(milliseconds: 500));

      // Step 4: Tutto pronto, navighiamo all'app principale
      setState(() {
        _loadingMessage = 'Pronto!';
      });
      
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const TarotApp()),
        );
      }

    } catch (e) {
      setState(() {
        _loadingMessage = 'Errore critico:\n$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2A4A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
            ),
            const SizedBox(height: 20),
            Text(
              _loadingMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}