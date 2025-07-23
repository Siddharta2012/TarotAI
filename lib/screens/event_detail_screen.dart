// lib/screens/event_detail_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tarot_ai_1/providers/application_providers.dart';

class EventDetailScreen extends ConsumerWidget {
  final DocumentSnapshot eventDoc;

  const EventDetailScreen({super.key, required this.eventDoc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = eventDoc.data() as Map<String, dynamic>;
    final String title = data['title'] ?? 'Nessun titolo';
    final String description = data['description'] ?? 'Nessuna descrizione';
    final String imageUrl = data['coverImageUrl'] ?? '';
    final Timestamp timestamp = data['eventDate'] ?? Timestamp.now();
    final String hostName = data['hostName'] ?? 'N/D';
    final double price = (data['price'] ?? 0.0).toDouble();
    final formattedDate = DateFormat('EEEE d MMMM yyyy, HH:mm', 'it_IT').format(timestamp.toDate());

    // Ascoltiamo lo stato di iscrizione per questo specifico evento
    final registrationStatus = ref.watch(eventRegistrationStatusProvider(eventDoc.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(height: 250, child: Icon(Icons.image_not_supported, size: 50)),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.calendar_today, color: Colors.deepPurpleAccent),
                    title: Text(formattedDate),
                    subtitle: const Text('Data e Ora dell\'Evento'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person, color: Colors.deepPurpleAccent),
                    title: Text('Tenuto da: $hostName'),
                  ),
                  ListTile(
                    leading: Icon(price == 0 ? Icons.celebration : Icons.euro_symbol, color: Colors.deepPurpleAccent),
                    title: Text(price == 0 ? 'Evento Gratuito' : 'Costo: ${price.toStringAsFixed(2)} €'),
                  ),
                  const Divider(height: 32),
                  Text('Descrizione', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(description, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 80), // Spazio per il pulsante
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // Il pulsante cambia in base allo stato di iscrizione
      floatingActionButton: registrationStatus.when(
        loading: () => const CircularProgressIndicator(),
        error: (err, stack) => const FloatingActionButton.extended(
          onPressed: null,
          label: Text('Errore'),
          icon: Icon(Icons.error),
        ),
        data: (docSnapshot) {
          final bool isRegistered = docSnapshot.exists;

          return FloatingActionButton.extended(
            onPressed: () async {
              final firestoreService = ref.read(firestoreServiceProvider);
              final user = ref.read(firebaseAuthProvider).currentUser;

              if (user == null || user.isAnonymous) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Devi essere registrato per iscriverti agli eventi.')),
                );
                return;
              }

              try {
                if (isRegistered) {
                  // Se è già registrato, annulla l'iscrizione
                  await firestoreService.unregisterUserFromEvent(user.uid, eventDoc.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Iscrizione annullata.'), backgroundColor: Colors.orange));
                  }
                } else {
                  // Altrimenti, registra
                  await firestoreService.registerUserForEvent(user.uid, eventDoc);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Iscrizione a "$title" confermata!'), backgroundColor: Colors.green));
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore: $e'), backgroundColor: Colors.red));
                }
              }
            },
            label: Text(isRegistered ? 'Annulla Iscrizione' : (price == 0 ? 'Partecipa Gratuitamente' : 'Acquista Biglietto')),
            icon: Icon(isRegistered ? Icons.cancel_outlined : Icons.check_circle_outline),
            backgroundColor: isRegistered ? Colors.grey.shade700 : Colors.green.shade700,
          );
        },
      ),
    );
  }
}
