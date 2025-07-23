// lib/screens/my_events_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tarot_ai_1/providers/application_providers.dart';
import 'package:tarot_ai_1/screens/event_detail_screen.dart';

class MyEventsScreen extends ConsumerWidget {
  const MyEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ascolta il provider che carica gli eventi a cui l'utente è iscritto.
    final myEventsAsyncValue = ref.watch(registeredEventsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('I Miei Eventi'),
      ),
      body: myEventsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Errore: $err')),
        data: (eventsSnapshot) {
          if (eventsSnapshot.docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Non sei ancora iscritto/a a nessun evento.\nEsplora il feed per trovarne di nuovi!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
              ),
            );
          }

          // Se ci sono eventi, li mostriamo in una lista.
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: eventsSnapshot.docs.length,
            itemBuilder: (context, index) {
              final eventDoc = eventsSnapshot.docs[index];
              final eventData = eventDoc.data() as Map<String, dynamic>;
              final String title = eventData['title'] ?? 'Evento sconosciuto';
              final Timestamp timestamp = eventData['eventDate'] ?? Timestamp.now();
              final formattedDate = DateFormat('EEEE d MMMM, HH:mm', 'it_IT').format(timestamp.toDate());

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: ListTile(
                  leading: const Icon(Icons.event_available, color: Colors.greenAccent),
                  title: Text(title),
                  subtitle: Text(formattedDate),
                  // Pulsante per annullare l'iscrizione.
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    tooltip: 'Annulla Iscrizione',
                    onPressed: () async {
                      final firestoreService = ref.read(firestoreServiceProvider);
                      final user = ref.read(firebaseAuthProvider).currentUser;
                      if (user != null) {
                        await firestoreService.unregisterUserFromEvent(user.uid, eventDoc.id);
                      }
                    },
                  ),
                  // Tocca per vedere i dettagli dell'evento originale.
                  onTap: () async {
                    final originalEventId = eventData['originalEventId'] as String?;
                    if (originalEventId != null) {
                      final fullEventDoc = await FirebaseFirestore.instance.collection('events').doc(originalEventId).get();
                      if (context.mounted && fullEventDoc.exists) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => EventDetailScreen(eventDoc: fullEventDoc)));
                      }
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
