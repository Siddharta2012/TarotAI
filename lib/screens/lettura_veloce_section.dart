import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/tarot_models.dart';
import '../widgets/tarot_card_widget.dart';
import 'spread_zoom_screen.dart';

class SpreadReadingScreen extends StatefulWidget {
  final TarotSpread spread;
  const SpreadReadingScreen({super.key, required this.spread});

  @override
  State<SpreadReadingScreen> createState() => _SpreadReadingScreenState();
}

class _SpreadReadingScreenState extends State<SpreadReadingScreen> {
  /* ----------------------- stato ----------------------- */
  final TextEditingController _questionController = TextEditingController();
  List<DrawnCard> _drawnCards = [];
  String _interpretation = '';
  bool _isLoading = false;

  /* ------------------- elenco completo carte ------------------- */
  final List<String> _tarotCardNames = const [
    // Arcani maggiori
    'Il Matto', 'Il Mago', 'La Papessa', 'L\'Imperatrice', 'L\'Imperatore',
    'Il Papa', 'Gli Amanti', 'Il Carro', 'La Giustizia', 'L\'Eremita',
    'La Ruota della Fortuna', 'La Forza', 'L\'Appeso', 'La Morte',
    'La Temperanza', 'Il Diavolo', 'La Torre', 'Le Stelle', 'La Luna',
    'Il Sole', 'Il Giudizio', 'Il Mondo',
    // Bastoni
    'Asso di Bastoni', 'Due di Bastoni', 'Tre di Bastoni', 'Quattro di Bastoni',
    'Cinque di Bastoni', 'Sei di Bastoni', 'Sette di Bastoni',
    'Otto di Bastoni', 'Nove di Bastoni', 'Dieci di Bastoni',
    'Fante di Bastoni', 'Cavaliere di Bastoni', 'Regina di Bastoni',
    'Re di Bastoni',
    // Coppe
    'Asso di Coppe', 'Due di Coppe', 'Tre di Coppe', 'Quattro di Coppe',
    'Cinque di Coppe', 'Sei di Coppe', 'Sette di Coppe', 'Otto di Coppe',
    'Nove di Coppe', 'Dieci di Coppe', 'Fante di Coppe',
    'Cavaliere di Coppe', 'Regina di Coppe', 'Re di Coppe',
    // Spade
    'Asso di Spade', 'Due di Spade', 'Tre di Spade', 'Quattro di Spade',
    'Cinque di Spade', 'Sei di Spade', 'Sette di Spade', 'Otto di Spade',
    'Nove di Spade', 'Dieci di Spade', 'Fante di Spade',
    'Cavaliere di Spade', 'Regina di Spade', 'Re di Spade',
    // Denari
    'Asso di Denari', 'Due di Denari', 'Tre di Denari', 'Quattro di Denari',
    'Cinque di Denari', 'Sei di Denari', 'Sette di Denari',
    'Otto di Denari', 'Nove di Denari', 'Dieci di Denari',
    'Fante di Denari', 'Cavaliere di Denari', 'Regina di Denari',
    'Re di Denari',
  ];

  /* ------------------- estrazione carte ------------------- */
  void _drawCards() {
    setState(() {
      _interpretation = '';
      final random = Random();
      final selected = <String>{};

      while (selected.length < widget.spread.numberOfCards) {
        selected.add(_tarotCardNames[random.nextInt(_tarotCardNames.length)]);
      }

      _drawnCards = List.generate(widget.spread.numberOfCards, (i) {
        return DrawnCard(
          name: selected.elementAt(i),
          position: widget.spread.cardPositions[i],
        );
      });
    });
  }

  /* ------------------- richiesta interpretazione ------------------- */
  Future<void> _getInterpretation() async {
    if (_drawnCards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Per favore, estrai prima le carte.')),
      );
      return;
    }
    if (_questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Per favore, inserisci la tua domanda.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    const apiKey =
        'AIzaSyDde0W8sQ3Mm27-khHOrZ82IitzGXRyjb4'; // <-- inserisci la tua API key di Gemini qui
    const url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey';

    final cardsDesc = _drawnCards.asMap().entries.map((e) {
      return '${e.key + 1}. ${e.value.name} (pos: ${e.value.position})';
    }).join('\n');

    final prompt = '''
Interpreta la stesa "${widget.spread.name}" (metodo Jodorowsky, approccio psicologico) per la domanda:
"${_questionController.text}"

Carte:
$cardsDesc

Fornisci un'interpretazione dettagliata e costruttiva collegando ogni carta alla sua posizione.
''';

    try {
      final res = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ]
        }),
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() => _interpretation =
            data['candidates'][0]['content']['parts'][0]['text']);
        _showSaveConfirmationDialog();
      } else {
        throw Exception('Errore API: ${res.body}');
      }
    } catch (e) {
      setState(() => _interpretation = 'Errore: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /* ------------------- salvataggio ------------------- */
  Future<void> _saveReading() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('readings')
        .add({
      'question': _questionController.text,
      'cards': _drawnCards
          .map((c) => {'name': c.name, 'position': c.position}).toList(),
      'interpretation': _interpretation,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lettura salvata nel diario.')),
    );
  }

  void _showSaveConfirmationDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Salva nel Diario'),
        content: const Text('Vuoi salvare questa lettura?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
          TextButton(
            onPressed: () {
              _saveReading();
              Navigator.pop(context);
            },
            child: const Text('Sì'),
          ),
        ],
      ),
    );
  }

  /* ------------------- UI ------------------- */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lettura: ${widget.spread.name}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(
                  labelText: 'Scrivi qui la tua domanda…'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.shuffle),
                    label: Text('Estrai ${widget.spread.numberOfCards} Carte'),
                    onPressed: _drawCards,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.psychology_alt),
                    label: const Text('Interpreta'),
                    onPressed: _isLoading ? null : _getInterpretation,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_drawnCards.isNotEmpty) _buildSpreadDisplay(),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_interpretation.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_interpretation),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /* ------------------- anteprima ------------------- */
  Widget _buildSpreadDisplay() {
    if (widget.spread.name == 'Croce Celtica' && _drawnCards.length >= 10) {
      return _buildCelticCrossPreview();
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 5 : 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.7,
      ),
      itemCount: _drawnCards.length,
      itemBuilder: (_, i) => TarotCardWidget(card: _drawnCards[i]),
    );
  }

  /* ------------------- Croce Celtica: preview ------------------- */
  Widget _buildCelticCrossPreview() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SpreadZoomScreen(cards: _drawnCards)),
      ),
      child: Container(
        height: 320, // ↑ era 300
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.deepPurple.shade300),
        ),
        child: Column(
          children: [
            Expanded(
              child: AbsorbPointer(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: _buildFullStaticLayout(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.zoom_in, size: 18, color: Colors.white70),
                const SizedBox(width: 8),
                const Text(
                  'Tocca per esplorare',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /* ------------------- mini-layout statico ------------------- */
  Widget _buildFullStaticLayout() {
    const double cardWidth = 85, cardHeight = 140; // ↑ 140
    const double hGap = 15, vGap = 15;

    const col0 = 0.0;
    const col1 = col0 + cardWidth + hGap;
    const col2 = col1 + cardWidth + hGap;
    const col3 = col2 + cardWidth + hGap;

    const row0 = 0.0;
    const row1 = row0 + cardHeight + vGap;
    const row2 = row1 + cardHeight + vGap;
    const row3 = row2 + cardHeight + vGap;

    final contentW = col3 + cardWidth;
    final contentH = row3 + cardHeight;

    return SizedBox(
      width: contentW,
      height: contentH,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: row1, left: col0, child: TarotCardWidget(card: _drawnCards[3])),
          Positioned(top: row1, left: col2, child: TarotCardWidget(card: _drawnCards[5])),
          Positioned(top: row0, left: col1, child: TarotCardWidget(card: _drawnCards[4])),
          Positioned(top: row2, left: col1, child: TarotCardWidget(card: _drawnCards[2])),
          Positioned(top: row1, left: col1, child: TarotCardWidget(card: _drawnCards[0])),
          Positioned(
            top: row1,
            left: col1,
            child: Transform.rotate(
              angle: pi / 2,
              child: TarotCardWidget(card: _drawnCards[1]),
            ),
          ),
          Positioned(top: row0, left: col3, child: TarotCardWidget(card: _drawnCards[9])),
          Positioned(top: row1, left: col3, child: TarotCardWidget(card: _drawnCards[8])),
          Positioned(top: row2, left: col3, child: TarotCardWidget(card: _drawnCards[7])),
          Positioned(top: row3, left: col3, child: TarotCardWidget(card: _drawnCards[6])),
        ],
      ),
    );
  }
}
