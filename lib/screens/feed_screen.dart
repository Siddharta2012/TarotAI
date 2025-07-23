// lib/screens/feed_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tarot_ai_1/models/eventbrite_event.dart'; // Importa il modello di Eventbrite
import 'package:tarot_ai_1/providers/application_providers.dart';
import 'package:tarot_ai_1/screens/event_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Leggiamo i dati sia da Firestore (come prima) sia da Eventbrite
    final firestoreEventsAsync = ref.watch(eventsStreamProvider);
    final eventbriteEventsAsync = ref.watch(eventbriteEventsProvider); // <-- NUOVO

    // La logica dei filtri rimane la stessa
    const List<String> categories = ['Tarocchi', 'Astrologia', 'Meditazione'];
    const List<String> formats = ['Online', 'In Presenza'];
    final selectedCategory = ref.watch(categoryFilterProvider);
    final selectedFormat = ref.watch(formatFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventi e Novità'),
      ),
      body: Column(
        children: [
          // SEZIONE FILTRI (invariata)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Categorie', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    children: categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: selectedCategory == category,
                          onSelected: (isSelected) {
                            ref.read(categoryFilterProvider.notifier).state = isSelected ? category : null;
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1),
          Expanded(
            // Usiamo un RefreshIndicator per permettere all'utente di ricaricare i dati
            child: RefreshIndicator(
              onRefresh: () async {
                // Invalida il provider per forzare un nuovo fetch dei dati da Eventbrite
                ref.invalidate(eventbriteEventsProvider);
              },
              child: ListView(
                children: [
                  // --- SEZIONE EVENTI DA EVENTBRITE (NUOVA) ---
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                    child: Text("Eventi dal Web", style: Theme.of(context).textTheme.titleLarge),
                  ),
                  eventbriteEventsAsync.when(
                    loading: () => const Center(child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    )),
                    error: (err, stack) => Center(child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Errore caricamento eventi: $err', style: const TextStyle(color: Colors.redAccent)),
                    )),
                    data: (events) {
                      if (events.isEmpty) {
                        return const Center(child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Nessun evento trovato sul web.'),
                        ));
                      }
                      return SizedBox(
                        height: 280, // Altezza fissa per la lista orizzontale
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            return EventbriteEventCard(event: events[index]);
                          },
                        ),
                      );
                    },
                  ),

                  // --- SEZIONE EVENTI DA FIRESTORE (ESISTENTE, ma adattata) ---
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
                    child: Text("Eventi Curati da Noi", style: Theme.of(context).textTheme.titleLarge),
                  ),
                  firestoreEventsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Errore: $err')),
                    data: (eventsSnapshot) {
                      if (eventsSnapshot.docs.isEmpty) {
                        return const Center(child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Nessun evento curato da noi al momento.'),
                        ));
                      }
                      // Usiamo `shrinkWrap` e `NeverScrollableScrollPhysics` per renderla
                      // parte del ListView verticale principale senza conflitti di scroll.
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: eventsSnapshot.docs.length,
                        itemBuilder: (context, index) {
                          final eventDoc = eventsSnapshot.docs[index];
                          return EventCard(eventDoc: eventDoc); // Il tuo widget esistente
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// !! --- NUOVO WIDGET PER LA CARD DI EVENTBRITE --- !!
class EventbriteEventCard extends StatelessWidget {
  final EventbriteEvent event;
  const EventbriteEventCard({super.key, required this.event});

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      print('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = event.startDate != null
        ? DateFormat('d MMM, HH:mm', 'it_IT').format(event.startDate!)
        : 'Data non specificata';

    return SizedBox(
      width: 250, // Larghezza fissa per la card nella lista orizzontale
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            if (event.url.isNotEmpty) {
              _launchURL(event.url);
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  // Immagine di copertina
                  if (event.imageUrl.isNotEmpty)
                    Image.network(
                      event.imageUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 150,
                        color: Colors.grey.shade800,
                        child: const Center(child: Icon(Icons.image_not_supported, color: Colors.white30, size: 40)),
                      ),
                    )
                  else
                    Container(
                      height: 150,
                      color: Colors.deepPurple.shade900,
                      child: const Center(child: Icon(Icons.travel_explore, color: Colors.white30, size: 40)),
                    ),
                  // Badge della fonte
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Chip(
                      label: const Text('Eventbrite', style: TextStyle(fontSize: 10)),
                      avatar: const Icon(Icons.open_in_new, size: 14),
                      padding: const EdgeInsets.all(4),
                      backgroundColor: Colors.black.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              // Dettagli dell'evento
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        event.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.white70),
                          const SizedBox(width: 8),
                          Text(formattedDate, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// Il tuo widget EventCard esistente, necessario per gli eventi da Firestore.
// Assicurati che sia presente nel file.
class EventCard extends StatelessWidget {
  final DocumentSnapshot eventDoc;
  const EventCard({super.key, required this.eventDoc});

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $urlString';
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = eventDoc.data() as Map<String, dynamic>;
    final String title = data['title'] ?? 'Nessun titolo';
    final String imageUrl = data['coverImageUrl'] ?? '';
    final Timestamp timestamp = data['eventDate'] ?? Timestamp.now();
    final formattedDate = DateFormat('EEEE d MMMM, HH:mm', 'it_IT').format(timestamp.toDate());
    
    final String source = data['source'] ?? 'Curato da noi';
    final String sourceUrl = data['sourceUrl'] ?? '';
    final bool isExternal = sourceUrl.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: InkWell(
        onTap: () {
          if (isExternal) {
            _launchURL(sourceUrl);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EventDetailScreen(eventDoc: eventDoc)),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                if (imageUrl.isNotEmpty)
                  Image.network(
                    imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: Colors.grey.shade800,
                      child: const Center(child: Icon(Icons.image_not_supported, color: Colors.white30, size: 50)),
                    ),
                  ),
                if (isExternal)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Chip(
                      label: Text(source, style: const TextStyle(fontSize: 10)),
                      avatar: const Icon(Icons.travel_explore, size: 14),
                      padding: const EdgeInsets.all(4),
                      backgroundColor: Colors.black.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.white70),
                      const SizedBox(width: 8),
                      Text(formattedDate, style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
