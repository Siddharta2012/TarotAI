// lib/screens/courses_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarot_ai_1/providers/application_providers.dart';
import 'package:tarot_ai_1/screens/course_detail_screen.dart';

class CoursesScreen extends ConsumerWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ascoltiamo il provider che carica i corsi da Firestore
    final coursesAsyncValue = ref.watch(coursesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Corsi di Tarocchi'),
      ),
      // Usiamo `when` per gestire in modo pulito tutti i possibili stati
      body: coursesAsyncValue.when(
        // Stato di caricamento iniziale
        loading: () => const Center(child: CircularProgressIndicator()),
        
        // Stato di errore (es. se i permessi non sono corretti)
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Errore nel caricare i corsi:\n$err',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ),
        
        // Stato in cui abbiamo ricevuto i dati da Firestore
        data: (coursesSnapshot) {
          // Se la lista di documenti è vuota, mostriamo un messaggio
          if (coursesSnapshot.docs.isEmpty) {
            return const Center(
              child: Text(
                'Nessun corso disponibile al momento.',
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
            );
          }

          // Se ci sono corsi, costruiamo la lista
          return ListView.builder(
            padding: const EdgeInsets.all(10.0), // Aggiungiamo un po' di spazio ai bordi
            itemCount: coursesSnapshot.docs.length,
            itemBuilder: (context, index) {
              final courseDoc = coursesSnapshot.docs[index];
              final courseData = courseDoc.data() as Map<String, dynamic>;

              // Estraiamo i dati con un valore di fallback per sicurezza
              final String title = courseData['title'] ?? 'Corso senza titolo';
              final String description = courseData['description'] ?? 'Nessuna descrizione disponibile.';
              final String imageUrl = courseData['coverImageUrl'] ?? '';

              // Ritorniamo una Card per ogni corso
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                clipBehavior: Clip.antiAlias, // Arrotonda anche l'immagine
                elevation: 4,
                child: InkWell(
                  onTap: () {
                    // Navighiamo alla schermata di dettaglio del corso
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseDetailScreen(
                          courseId: courseDoc.id,
                          courseTitle: title,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Immagine di copertina
                      if (imageUrl.isNotEmpty)
                        Image.network(
                          imageUrl,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          // Gestore di errori per l'immagine
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 160,
                              color: Colors.grey.shade800,
                              child: const Center(
                                child: Icon(
                                  Icons.school_outlined, // Icona a tema
                                  color: Colors.white38,
                                  size: 60,
                                ),
                              ),
                            );
                          },
                        ),
                      
                      // Dettagli del corso
                      ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}