// lib/screens/abbonamenti_screen.dart

import 'package:flutter/foundation.dart'; // Importiamo kDebugMode
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Importiamo Riverpod
import '../providers/application_providers.dart'; // Importiamo i provider

// 1. Trasformiamo il widget in un ConsumerWidget per accedere a `ref`
class AbbonamentiScreen extends ConsumerWidget {
  const AbbonamentiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Abbonamenti e Gettoni'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 2. Aggiungiamo il pacchetto sviluppatore, visibile solo in modalità DEBUG
          if (kDebugMode)
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pacchetto Sviluppatore',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Aggiungi istantaneamente 10 Gettoni Mistici al tuo account per scopi di test.',
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Aggiungi 10 Gettoni (Gratis)'),
                        onPressed: () async {
                          // Otteniamo i servizi e l'utente dai provider
                          final firestoreService = ref.read(firestoreServiceProvider);
                          final user = ref.read(firebaseAuthProvider).currentUser;

                          if (user != null) {
                            await firestoreService.addDeveloperTokens(user.uid);
                            
                            // Mostriamo un messaggio di conferma
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('10 gettoni sviluppatore aggiunti!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Pacchetti esistenti (puoi aggiungerne altri qui)
          const Card(
            elevation: 2,
            child: ListTile(
              leading: Icon(Icons.star, color: Colors.amber),
              title: Text('Pacchetto Apprendista'),
              subtitle: Text('50 Gettoni Mistici'),
              trailing: Text('€ 4.99'),
            ),
          ),
          const Card(
            elevation: 2,
            child: ListTile(
              leading: Icon(Icons.stars, color: Colors.lightBlueAccent),
              title: Text('Pacchetto Adepto'),
              subtitle: Text('120 Gettoni Mistici'),
              trailing: Text('€ 9.99'),
            ),
          ),
        ],
      ),
    );
  }
}