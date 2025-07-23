// lib/screens/lesson_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LessonScreen extends StatelessWidget {
  final DocumentSnapshot lessonDoc;

  const LessonScreen({super.key, required this.lessonDoc});

  @override
  Widget build(BuildContext context) {
    final data = lessonDoc.data() as Map<String, dynamic>;
    final String title = data['title'] ?? 'Nessun titolo';
    final String content = data['content'] ?? 'Contenuto non disponibile.';

    return Scaffold(
      appBar: AppBar(
        title: Text(title, overflow: TextOverflow.ellipsis),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          content,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.check_circle),
          label: const Text('Lezione Completata'),
          onPressed: () {
            // Per ora, torniamo indietro. In futuro qui tracceremo il progresso.
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }
}