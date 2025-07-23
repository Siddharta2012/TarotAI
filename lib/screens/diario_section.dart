import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'reading_detail_screen.dart';

class DiarioSection extends StatelessWidget {
  const DiarioSection({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("Per favore, accedi per vedere il tuo diario."));
    }

    // Stream per ricevere le letture da Firestore in tempo reale
    final readingsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('readings')
        .orderBy('timestamp', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: readingsStream,
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
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _confirmDelete(context, reading.reference),
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
    );
  }

  // Mostra un dialogo di conferma prima di eliminare una lettura
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
