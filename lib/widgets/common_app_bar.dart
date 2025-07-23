import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/firestore_service.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CommonAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    // Ottiene le istanze dei servizi qui per essere più sicuro
    final FirestoreService firestoreService = FirestoreService();
    final User? user = FirebaseAuth.instance.currentUser;

    return AppBar(
      title: Text(title),
      centerTitle: true,
      actions: [
        // Mostra il saldo dei gettoni solo se l'utente è loggato
        if (user != null)
          StreamBuilder<DocumentSnapshot>(
            stream: firestoreService.getUserStream(user.uid),
            builder: (context, snapshot) {
              // Mentre i dati caricano, mostra un piccolo spinner
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                );
              }
              // Se ci sono errori o i dati non esistono, mostra un placeholder
              if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Chip(
                    avatar: Icon(Icons.stars, color: Colors.grey, size: 18),
                    label: const Text('?'),
                    backgroundColor: Colors.deepPurple.shade900,
                  ),
                );
              }
              // Se i dati sono disponibili, mostra il saldo
              final tokens = (snapshot.data!.data() as Map<String, dynamic>)['tokens'] ?? 0;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Chip(
                  avatar: Icon(Icons.stars, color: Colors.yellow.shade700, size: 18),
                  label: Text('$tokens', style: const TextStyle(fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.deepPurple.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
              );
            },
          ),
        // Bottone per il logout
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: () async {
            await GoogleSignIn().signOut();
            await FirebaseAuth.instance.signOut();
            // Dopo il logout, torna alla schermata di login e pulisce lo stack di navigazione
            // Questo evita che l'utente possa tornare indietro a schermate protette.
            if (context.mounted) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
