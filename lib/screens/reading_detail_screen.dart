// lib/screens/reading_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; // Importa il pacchetto
import '../models/tarot_models.dart';
import '../widgets/user_status_bar.dart';
import '../widgets/tarot_card_widget.dart';

class ReadingDetailScreen extends StatelessWidget {
  final Map<String, dynamic> readingData;

  const ReadingDetailScreen({super.key, required this.readingData});

  /// Funzione helper per formattare il testo da condividere
  void _shareReading(BuildContext context) {
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
    
    // Otteniamo la posizione del pulsante per un'esperienza migliore su iPad
    final box = context.findRenderObject() as RenderBox?;
    Share.share(
      shareText,
      subject: 'La mia lettura dei Tarocchi!', // Oggetto per le email
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> cardsData = readingData['cards'] ?? [];
    final List<DrawnCard> cards = cardsData.map((c) {
      return DrawnCard(name: c['name'], position: c['position'] ?? '');
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettaglio Lettura'),
        // Aggiungiamo il pulsante di condivisione qui
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Condividi Lettura',
            onPressed: () => _shareReading(context),
          ),
        ],
      ),
      body: Column(
        children: [
          const UserStatusBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Domanda:', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(readingData['question'] ?? 'N/A', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 24),
                  Text('Carte Estratte:', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 5 : 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      return TarotCardWidget(card: cards[index]);
                    },
                  ),
                  const SizedBox(height: 24),
                  Text('Interpretazione:', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        readingData['interpretation'] ?? 'Nessuna interpretazione disponibile.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
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