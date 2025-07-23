import 'package:flutter/material.dart';
import '../models/tarot_models.dart';
import '../widgets/user_status_bar.dart';
import 'spread_reading_screen.dart';

class AdvancedSpreadsScreen extends StatelessWidget {
  const AdvancedSpreadsScreen({super.key});

  final List<TarotSpread> spreads = const [
    TarotSpread(
      name: 'Croce Celtica',
      description: 'Una stesa completa per un\'analisi approfondita di una situazione.',
      numberOfCards: 10,
      cardPositions: [
        'Il Consultante', 'L\'Ostacolo', 'La Causa / La Base', 'Il Passato Recente',
        'Il Futuro Immediato', 'La Mente del Consultante', 'Le Influenze Esterne',
        'Le Speranze e Paure', 'Il Consiglio', 'L\'Esito Finale'
      ],
    ),
    TarotSpread(
      name: 'Stesa a Tre Carte',
      description: 'Una stesa semplice per analizzare Passato, Presente e Futuro.',
      numberOfCards: 3,
      cardPositions: ['Passato', 'Presente', 'Futuro'],
    ),
    TarotSpread(
      name: 'Stesa Relazionale',
      description: 'Analizza la dinamica tra due persone o aspetti di sé.',
      numberOfCards: 5,
      cardPositions: ['Tu', 'L\'Altro', 'La Dinamica', 'Il Consiglio', 'L\'Esito'],
    ),
    TarotSpread(
      name: 'Ferro di Cavallo',
      description: 'Analizza un percorso in 7 passi, dal passato al futuro.',
      numberOfCards: 7,
      cardPositions: ['Passato', 'Presente', 'Sviluppi Futuri', 'Il Consultante', 'Ambiente', 'Ostacoli', 'Esito'],
    ),
     TarotSpread(
      name: 'Stesa a una Carta',
      description: 'Una risposta rapida o un consiglio per la giornata.',
      numberOfCards: 1,
      cardPositions: ['Il Consiglio del Giorno'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scegli una Stesa')),
      body: Column(
        children: [
          const UserStatusBar(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: spreads.length,
              itemBuilder: (context, index) {
                final spread = spreads[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: ListTile(
                    title: Text(spread.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(spread.description),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SpreadReadingScreen(spread: spread),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
