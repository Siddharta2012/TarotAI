// lib/screens/lettura_veloce_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Importa Riverpod
import '../models/tarot_models.dart';
import '../providers/application_providers.dart'; // Importa i provider
import '../widgets/tarot_card_widget.dart';
import '../widgets/user_status_bar.dart';
import 'abbonamenti_screen.dart';

// Trasforma il widget in un ConsumerStatefulWidget
class LetturaVeloceScreen extends ConsumerStatefulWidget {
  const LetturaVeloceScreen({super.key});

  @override
  ConsumerState<LetturaVeloceScreen> createState() => _LetturaVeloceScreenState();
}

class _LetturaVeloceScreenState extends ConsumerState<LetturaVeloceScreen> {
  final TextEditingController _questionController = TextEditingController();
  
  List<DrawnCard> _drawnCards = [];
  String _interpretation = '';
  bool _isLoading = false;

  void _drawCards() {
    // Usiamo ref.read per ottenere l'istanza del servizio dal provider
    final deckService = ref.read(tarotDeckServiceProvider);
    setState(() {
      _interpretation = '';
      _drawnCards = deckService.drawCards(
        count: 3, 
        positions: ['Passato', 'Presente', 'Futuro']
      );
    });
  }

  Future<void> _getInterpretation() async {
    // Leggiamo i servizi e i dati necessari dai provider
    final firestoreService = ref.read(firestoreServiceProvider);
    final apiService = ref.read(tarotApiServiceProvider);
    final user = ref.read(firebaseAuthProvider).currentUser;

    if (user == null) return;

    // ... (la logica di controllo rimane la stessa)
    if (_drawnCards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Per favore, estrai prima le carte.')));
      return;
    }
    if (_questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Per favore, inserisci la tua domanda.')));
      return;
    }

    setState(() => _isLoading = true);

    const readingCost = 2;
    // Gli utenti anonimi hanno gettoni infiniti per provare l'app
    final hasTokens = user.isAnonymous ? true : await firestoreService.hasEnoughTokens(user.uid, readingCost);

    if (!hasTokens) {
      _showInsufficientTokensDialog();
      setState(() => _isLoading = false);
      return;
    }

    final prompt = """
    Interpreta la seguente stesa di tre carte (passato, presente, futuro)...
    Le carte sono:
    1. ${_drawnCards[0].name} (Posizione: ${_drawnCards[0].position})
    2. ${_drawnCards[1].name} (Posizione: ${_drawnCards[1].position})
    3. ${_drawnCards[2].name} (Posizione: ${_drawnCards[2].position})
    ...
    """;

    try {
      final interpretationResult = await apiService.getInterpretation(prompt);
      
      if (!user.isAnonymous) {
        await firestoreService.deductTokens(user.uid, readingCost);
      }

      setState(() { _interpretation = interpretationResult; });
      _showSaveConfirmationDialog();

    } catch (e) {
      setState(() { _interpretation = 'Errore: $e'; });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ... (Il resto del file, inclusi i dialoghi e la UI, rimane quasi identico)
  // ... (omesso per brevità, non devi cambiarlo)
  
  // Aggiungi questo metodo per completezza
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

  // Aggiungi questo metodo per completezza
  void _showSaveConfirmationDialog() {
    final user = ref.read(firebaseAuthProvider).currentUser;
    // Non chiediamo di salvare se l'utente è un ospite
    if (user == null || user.isAnonymous) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Salva nel Diario'),
          content: const Text('Vuoi salvare questa lettura nel tuo diario?'),
          actions: <Widget>[
            TextButton(child: const Text('No'), onPressed: () => Navigator.of(context).pop()),
            TextButton(
              child: const Text('Sì'),
              onPressed: () {
                _saveReading();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Aggiungi questo metodo per completezza
  Future<void> _saveReading() async {
    final user = ref.read(firebaseAuthProvider).currentUser;
    if (user == null || user.isAnonymous) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('readings').add({
      'question': _questionController.text,
      'cards': _drawnCards.map((c) => {'name': c.name, 'position': c.position}).toList(),
      'interpretation': _interpretation,
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lettura salvata nel diario.')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // ... La UI non cambia ...
    return Scaffold(
      appBar: AppBar(title: const Text('Lettura Veloce')),
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
                    decoration: const InputDecoration(
                      labelText: 'Scrivi qui la tua domanda...',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.shuffle),
                    label: const Text('Estrai 3 Carte'),
                    onPressed: _drawCards,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.psychology_alt),
                    label: const Text('Interpreta (2 Gettoni)'),
                    onPressed: _isLoading ? null : _getInterpretation,
                  ),
                  const SizedBox(height: 20),
                  if (_drawnCards.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: _drawnCards.length,
                      itemBuilder: (context, index) {
                        return TarotCardWidget(card: _drawnCards[index]);
                      },
                    ),
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
}