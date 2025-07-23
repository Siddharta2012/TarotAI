// lib/screens/reading_hub_screen.dart

import 'package:flutter/material.dart';
import 'package:tarot_ai_1/screens/advanced_spreads_screen.dart';
import 'package:tarot_ai_1/screens/lettura_veloce_screen.dart';
import 'package:tarot_ai_1/widgets/user_status_bar.dart';

class ReadingHubScreen extends StatelessWidget {
  const ReadingHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scegli il Tuo Consulto'),
      ),
      body: Column(
        children: [
          // Manteniamo la barra di stato per coerenza
          const UserStatusBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Bottone per la Lettura Veloce
                  ElevatedButton.icon(
                    icon: const Icon(Icons.bolt),
                    label: const Text('Lettura Veloce (3 Carte)'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LetturaVeloceScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // Bottone per le Letture Approfondite
                  ElevatedButton.icon(
                    icon: const Icon(Icons.view_carousel),
                    label: const Text('Letture Approfondite'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      textStyle: const TextStyle(fontSize: 18),
                      backgroundColor: Colors.deepPurple.shade700,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdvancedSpreadsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}