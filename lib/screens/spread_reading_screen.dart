// lib/screens/spread_reading_screen.dart

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/tarot_models.dart';
import '../services/firestore_service.dart';
import '../services/tarot_api_service.dart';
import '../services/tarot_deck_service.dart';
import '../widgets/tarot_card_widget.dart';
import '../widgets/user_status_bar.dart';
import 'abbonamenti_screen.dart';
import 'spread_zoom_screen.dart';

class SpreadReadingScreen extends StatefulWidget {
  final TarotSpread spread;

  const SpreadReadingScreen({super.key, required this.spread});

  @override
  State<SpreadReadingScreen> createState() => _SpreadReadingScreenState();
}

class _SpreadReadingScreenState extends State<SpreadReadingScreen> {
  // Istanziamo i nostri servizi
  final TextEditingController _questionController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final TarotDeckService _deckService = TarotDeckService();
  final TarotApiService _apiService = TarotApiService();

  // Lo stato del widget
  List<DrawnCard> _drawnCards = [];
  String _interpretation = '';
  bool _isLoading = false;

  void _drawCards() {
    setState(() {
      _interpretation = '';
      _drawnCards = _deckService.drawCards(
        count: widget.spread.numberOfCards,
        positions: widget.spread.cardPositions,
      );
    });
  }

  Future<void> _getInterpretation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_drawnCards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Per favore, estrai prima le carte.')));
      return;
    }
    if (_questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Per favore, inserisci la tua domanda.')));
      return;
    }

    setState(() => _isLoading = true);

    const readingCost = 5;
    final hasTokens = await _firestoreService.hasEnoughTokens(user.uid, readingCost);

    if (!hasTokens) {
      _showInsufficientTokensDialog();
      setState(() => _isLoading = false);
      return;
    }

    final cardsDescription = _drawnCards.asMap().entries.map((entry) {
      return "${entry.key + 1}. ${entry.value.name} (Posizione: ${entry.value.position})";
    }).join('\n');

    final prompt = """
    Interpreta la seguente stesa di Tarocchi "${widget.spread.name}" usando il metodo Jodorowsky (psicologico, non divinatorio) per la domanda: "${_questionController.text}".
    Le carte e le loro posizioni sono:
    $cardsDescription
    Fornisci un'interpretazione dettagliata e costruttiva, collegando il significato di ogni carta alla sua posizione specifica e creando una narrazione coerente.
    """;

    try {
      final interpretationResult = await _apiService.getInterpretation(prompt);
      
      await _firestoreService.deductTokens(user.uid, readingCost);

      setState(() => _interpretation = interpretationResult);
      _showSaveConfirmationDialog();

    } catch (e) {
      setState(() => _interpretation = 'Errore nel ricevere l\'interpretazione: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showInsufficientTokensDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Gettoni Insufficienti'),
        content: const Text('Non hai abbastanza Gettoni Mistici per questa lettura. Visita la sezione Abbonamenti per ricaricare.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Annulla')),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AbbonamentiScreen()));
            },
            child: const Text('Vai agli Abbonamenti'),
          ),
        ],
      ),
    );
  }

  void _showSaveConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Salva nel Diario'),
          content: const Text('Vuoi salvare questa lettura nel tuo diario?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('No')),
            TextButton(
              onPressed: () {
                _saveReading();
                Navigator.of(context).pop();
              },
              child: const Text('Sì'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveReading() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('readings').add({
      'question': _questionController.text,
      'cards': _drawnCards.map((c) => {'name': c.name, 'position': c.position}).toList(),
      'interpretation': _interpretation,
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lettura salvata nel diario.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lettura: ${widget.spread.name}')),
      body: Column(
        children: [
          const UserStatusBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _questionController,
                    decoration: const InputDecoration(labelText: 'Scrivi qui la tua domanda...'),
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
                          label: const Text('Interpreta (5 Gettoni)'),
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
                        padding: const EdgeInsets.all(16.0),
                        child: Text(_interpretation, style: Theme.of(context).textTheme.bodyMedium),
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
      itemBuilder: (context, index) => TarotCardWidget(card: _drawnCards[index]),
    );
  }

  Widget _buildCelticCrossPreview() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SpreadZoomScreen(cards: _drawnCards),
          ),
        );
      },
      child: Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.deepPurple.shade300, width: 1),
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
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.zoom_in, size: 18, color: Colors.white70),
                SizedBox(width: 8),
                Text(
                  "Tocca per esplorare e zoomare",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullStaticLayout() {
    const double cardWidth = 85.0;
    const double cardHeight = 125.0;
    const double hGap = 15.0;
    const double vGap = 15.0;

    const double col0 = 0;
    const double col1 = col0 + cardWidth + hGap;
    const double col2 = col1 + cardWidth + hGap;
    const double col3 = col2 + cardWidth + hGap;

    const double row0 = 0;
    const double row1 = row0 + cardHeight + vGap;
    const double row2 = row1 + cardHeight + vGap;
    const double row3 = row2 + cardHeight + vGap;

    final double contentWidth = col3 + cardWidth;
    final double contentHeight = row3 + cardHeight;

    return SizedBox(
      width: contentWidth,
      height: contentHeight,
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