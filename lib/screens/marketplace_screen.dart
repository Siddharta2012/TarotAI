// lib/screens/marketplace_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarot_ai_1/providers/application_providers.dart';
import 'package:tarot_ai_1/screens/practitioner_profile_screen.dart';
import '../models/marketplace_models.dart';
import '../widgets/common_app_bar.dart';

class MarketplaceScreen extends ConsumerWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final practitionersAsync = ref.watch(practitionersStreamProvider);

    return Scaffold(
      appBar: CommonAppBar(title: 'Operatori Esoterici'),
      body: practitionersAsync.when(
        data: (practitioners) {
          if (practitioners.isEmpty) {
            return const Center(child: Text('Nessun operatore disponibile al momento.'));
          }
          return ListView.builder(
            itemCount: practitioners.length,
            itemBuilder: (context, index) {
              final practitioner = practitioners[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(practitioner.photoUrl),
                    radius: 30,
                  ),
                  title: Text(practitioner.displayName),
                  subtitle: Text(practitioner.specializations.join(', '), maxLines: 1),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PractitionerProfileScreen(practitioner: practitioner),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Errore: $err')),
      ),
    );
  }
}