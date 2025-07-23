// lib/screens/practitioner_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tarot_ai_1/providers/application_providers.dart';
import '../models/marketplace_models.dart';

class PractitionerProfileScreen extends StatelessWidget {
  final PractitionerProfile practitioner;

  const PractitionerProfileScreen({super.key, required this.practitioner});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(practitioner.displayName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(practitioner.photoUrl),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(practitioner.displayName, style: Theme.of(context).textTheme.titleLarge),
                      Text(practitioner.specializations.join(', '), style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Chi sono', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(practitioner.bio),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text('I miei servizi', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            _ServicesList(practitionerId: practitioner.id),
          ],
        ),
      ),
    );
  }
}

class _ServicesList extends ConsumerWidget {
  final String practitionerId;

  const _ServicesList({required this.practitionerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesStreamProvider(practitionerId));
    
    return servicesAsync.when(
      data: (services) {
        if (services.isEmpty) {
          return const Text('Nessun servizio offerto.');
        }
        // Usiamo Column invece di ListView perché siamo già in uno SingleChildScrollView
        return Column(
          children: services.map((service) {
            return Card(
              child: ListTile(
                title: Text(service.title),
                subtitle: Text(service.description, maxLines: 2, overflow: TextOverflow.ellipsis,),
                trailing: Text('${service.price.toStringAsFixed(0)} €'),
                onTap: () {
                  // Qui in futuro andrà la logica per la prenotazione/pagamento
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Funzionalità di prenotazione per "${service.title}" non ancora implementata.'))
                  );
                },
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Errore nel caricare i servizi: $err'),
    );
  }
}