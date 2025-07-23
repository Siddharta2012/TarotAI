// lib/services/tarot_deck_service.dart

import 'dart:math';
import '../models/tarot_models.dart';

class TarotDeckService {
  // La lista completa delle carte, definita in un unico posto.
  final List<String> _tarotCardNames = const [
    "Il Matto", "Il Mago", "La Papessa", "L'Imperatrice", "L'Imperatore",
    "Il Papa", "Gli Amanti", "Il Carro", "La Giustizia", "L'Eremita",
    "La Ruota della Fortuna", "La Forza", "L'Appeso", "La Morte",
    "La Temperanza", "Il Diavolo", "La Torre", "Le Stelle", "La Luna", "Il Sole",
    "Il Giudizio", "Il Mondo",
    "Asso di Bastoni", "Due di Bastoni", "Tre di Bastoni", "Quattro di Bastoni", "Cinque di Bastoni",
    "Sei di Bastoni", "Sette di Bastoni", "Otto di Bastoni", "Nove di Bastoni", "Dieci di Bastoni",
    "Fante di Bastoni", "Cavaliere di Bastoni", "Regina di Bastoni", "Re di Bastoni",
    "Asso di Coppe", "Due di Coppe", "Tre di Coppe", "Quattro di Coppe", "Cinque di Coppe",
    "Sei di Coppe", "Sette di Coppe", "Otto di Coppe", "Nove di Coppe", "Dieci di Coppe",
    "Fante di Coppe", "Cavaliere di Coppe", "Regina di Coppe", "Re di Coppe",
    "Asso di Spade", "Due di Spade", "Tre di Spade", "Quattro di Spade", "Cinque di Spade",
    "Sei di Spade", "Sette di Spade", "Otto di Spade", "Nove di Spade", "Dieci di Spade",
    "Fante di Spade", "Cavaliere di Spade", "Regina di Spade", "Re di Spade",
    "Asso di Denari", "Due di Denari", "Tre di Denari", "Quattro di Denari", "Cinque di Denari",
    "Sei di Denari", "Sette di Denari", "Otto di Denari", "Nove di Denari", "Dieci di Denari",
    "Fante di Denari", "Cavaliere di Denari", "Regina di Denari", "Re di Denari"
  ];

  /// Estrae un numero specifico di carte uniche dal mazzo.
  ///
  /// [count] è il numero di carte da estrarre.
  /// [positions] è una lista opzionale di nomi per le posizioni delle carte.
  List<DrawnCard> drawCards({required int count, List<String>? positions}) {
    if (count > _tarotCardNames.length) {
      throw ArgumentError('Non puoi estrarre più carte di quante ce ne siano nel mazzo.');
    }
    if (positions != null && positions.length != count) {
      throw ArgumentError('Il numero di posizioni deve corrispondere al numero di carte da estrarre.');
    }

    final random = Random();
    final Set<String> selectedCards = {};

    // Estrae carte uniche finché non ne abbiamo il numero richiesto
    while (selectedCards.length < count) {
      selectedCards.add(_tarotCardNames[random.nextInt(_tarotCardNames.length)]);
    }

    // Crea la lista di oggetti DrawnCard, assegnando le posizioni
    return List.generate(count, (i) {
      return DrawnCard(
        name: selectedCards.elementAt(i),
        // Se le posizioni sono fornite, usa la posizione i-esima, altrimenti usa una stringa vuota
        position: (positions != null && i < positions.length) ? positions[i] : '',
      );
    });
  }
}