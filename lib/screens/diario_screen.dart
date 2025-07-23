// lib/screens/diario_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Importa Riverpod
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart'; // Importa il pacchetto di condivisione
import '../providers/application_providers.dart'; // Importa i provider
import '../widgets/user_status_bar.dart';
import 'reading_detail_screen.dart';

// Trasformiamo il widget in un ConsumerWidget per accedere a `ref`
class DiarioScreen extends ConsumerWidget {
  const DiarioScreen({super.key});

  /// Funzione helper per formattare il testo da condividere
  void _shareReading(Map<String, dynamic> readingData) {
    final String question = readingData['question'] ?? 'Nessuna domanda';
    final List<dynamic> cardsData = readingData['cards'] ?? [];
    final String interpretation = readingData['interpretation'] ?? 'Nessuna interpretazione.';

    final cardsList = cardsData.map((c) {
      return "- ${c['name']} (Posizione: ${c['position']})";
    }).join('\n');

    final String shareText = """
🔮 La Mia Lettura con Tarocchi AI 🔮

🤔 La Mia Domanda:
$question

🃏 Carte Estratte:
$cardsList

💡 Interpretazione dell'AI:
$interpretation

---
Generato da Tarocchi AI
""";

    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Otteniamo l'utente dal provider di Riverpod
    final user = ref.watch(firebaseAuthProvider).currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Diario delle Letture')),
      body: Column(
        children: [
          const UserStatusBar(),
          Expanded(
            child: user == null || user.isAnonymous
                ? const Center(child: Text("Il diario è disponibile solo per gli utenti registrati."))
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('readings')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("Non ci sono ancora letture salvate."));
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text("Errore: ${snapshot.error}"));
                      }

                      final readings = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: readings.length,
                        itemBuilder: (context, index) {
                          final reading = readings[index];
                          final data = reading.data() as Map<String, dynamic>;
                          final timestamp = data['timestamp'] as Timestamp?;
                          final dateTime = timestamp?.toDate();

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text(data['question'] ?? 'Senza domanda', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                dateTime != null
                                    ? DateFormat('dd/MM/yyyy, HH:mm').format(dateTime)
                                    : 'Data non disponibile',
                              ),
                              // Aggiungiamo una Row per contenere entrambi i pulsanti
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min, // Occupa solo lo spazio necessario
                                children: [
                                  // Pulsante di condivisione
                                  IconButton(
                                    icon: const Icon(Icons.share, color: Colors.blueAccent),
                                    tooltip: 'Condividi Lettura',
                                    onPressed: () => _shareReading(data),
                                  ),
                                  // Pulsante di eliminazione
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                                    tooltip: 'Elimina Lettura',
                                    onPressed: () => _confirmDelete(context, reading.reference),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReadingDetailScreen(readingData: data),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, DocumentReference reference) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conferma Eliminazione'),
          content: const Text('Sei sicuro di voler eliminare questa lettura? L\'azione è irreversibile.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () {
                reference.delete();
                Navigator.of(context).pop();
              },
              child: const Text('Elimina', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }
}