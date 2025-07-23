// lib/screens/course_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarot_ai_1/providers/application_providers.dart';
import 'package:tarot_ai_1/screens/lesson_screen.dart';

class CourseDetailScreen extends ConsumerWidget {
  final String courseId;
  final String courseTitle;

  const CourseDetailScreen({super.key, required this.courseId, required this.courseTitle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsyncValue = ref.watch(lessonsStreamProvider(courseId));

    return Scaffold(
      appBar: AppBar(
        title: Text(courseTitle),
      ),
      body: lessonsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Errore nel caricare le lezioni: $err')),
        data: (lessonsSnapshot) {
          if (lessonsSnapshot.docs.isEmpty) {
            return const Center(child: Text('Nessuna lezione trovata per questo corso.'));
          }

          return ListView.builder(
            itemCount: lessonsSnapshot.docs.length,
            itemBuilder: (context, index) {
              final lessonDoc = lessonsSnapshot.docs[index];
              
              // !! --- LA NOSTRA CORREZIONE È QUI --- !!
              // Prima di usare i dati, controlliamo se esistono.
              if (!lessonDoc.exists || lessonDoc.data() == null) {
                // Se un documento è vuoto o corrotto, mostriamo un placeholder
                // invece di far crashare l'app.
                return const ListTile(
                  leading: CircleAvatar(child: Icon(Icons.error_outline)),
                  title: Text('Lezione non valida'),
                );
              }

              final lessonData = lessonDoc.data() as Map<String, dynamic>;
              final String lessonTitle = lessonData['title'] ?? 'Lezione senza titolo';
              final int lessonOrder = lessonData['order'] ?? 0;

              return ListTile(
                leading: CircleAvatar(child: Text('$lessonOrder')),
                title: Text(lessonTitle),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LessonScreen(lessonDoc: lessonDoc),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}