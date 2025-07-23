// lib/widgets/user_status_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../main.dart'; // Importiamo main.dart per avere AppLauncher
import '../providers/application_providers.dart';
import '../screens/abbonamenti_screen.dart';

class UserStatusBar extends ConsumerWidget {
  const UserStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStream = ref.watch(userStreamProvider);
    final user = ref.watch(authStateChangesProvider).asData?.value;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (user != null && !user.isAnonymous)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AbbonamentiScreen()),
                );
              },
              child: userStream.when(
                data: (userDoc) {
                  if (userDoc != null && userDoc.exists) {
                    final tokens = (userDoc.data() as Map<String, dynamic>)['tokens'] ?? 0;
                    return Chip(
                      avatar: Icon(Icons.stars, color: Colors.yellow.shade700, size: 18),
                      label: Text('$tokens Gettoni', style: const TextStyle(fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.deepPurple.shade700,
                    );
                  }
                  return const Chip(label: Text('0 Gettoni')); // Mostra 0 se il doc non esiste
                },
                loading: () => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                error: (_, __) => const Chip(label: Text('Errore')),
              ),
            ),
          
          if (user != null && user.isAnonymous)
            const Chip(avatar: Icon(Icons.person_outline, size: 18), label: Text('Ospite')),

          if (user == null) const Spacer(),

          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                // Per evitare errori di contesto dopo un'operazione asincrona
                final navigator = Navigator.of(context);
                final auth = ref.read(firebaseAuthProvider);

                await GoogleSignIn().signOut();
                await auth.signOut();

                // Questa è la magia: rimuove tutte le schermate e ti riporta
                // all'inizio, dove AuthWrapper mostrerà la schermata di login.
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AppLauncher()),
                  (Route<dynamic> route) => false,
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.redAccent),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.account_circle, size: 30),
          ),
        ],
      ),
    );
  }
}