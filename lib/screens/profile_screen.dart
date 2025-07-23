// lib/screens/profile_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarot_ai_1/providers/application_providers.dart';
import 'package:tarot_ai_1/screens/abbonamenti_screen.dart';
import 'package:tarot_ai_1/screens/my_events_screen.dart';
import 'package:tarot_ai_1/widgets/user_status_bar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilo e Impostazioni'),
      ),
      body: Column(
        children: [
          const UserStatusBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              children: [
                ListTile(
                  leading: const Icon(Icons.stars_rounded),
                  title: const Text('Gettoni & Abbonamenti'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AbbonamentiScreen()),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.event_note_rounded),
                  title: const Text('I Miei Eventi'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyEventsScreen()),
                    );
                  },
                ),
                const Divider(),

                // !! --- SEZIONE DI DEBUG CON IL PULSANTE DI TEST --- !!
                if (kDebugMode)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AREA DEBUG',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.bug_report),
                          label: const Text('Test Eventbrite API (cerca "Tarocchi")'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade800,
                          ),
                          onPressed: () async {
                            // Mostra un messaggio di caricamento
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Chiamata API in corso...')),
                            );
                            try {
                              // ** LA CORREZIONE È QUI **
                              // Usiamo il nuovo nome del metodo `fetchEvents`
                              final events = await ref.read(eventbriteServiceProvider).fetchEvents(query: 'tarocchi');
                              
                              // Stampiamo i risultati nel log per il debug
                              print('--- TEST API DA PROFILO: TROVATI ${events.length} EVENTI ---');
                              for (var event in events) {
                                print('Nome: ${event.name}, URL: ${event.url}');
                              }

                              // Mostra un messaggio di successo
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${events.length} eventi trovati e stampati nel log di debug.'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              // Mostra un messaggio di errore
                               if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Errore API: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
