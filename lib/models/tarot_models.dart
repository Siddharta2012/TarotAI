// Modello per una singola Stesa di Tarocchi
class TarotSpread {
  final String name;
  final String description;
  final int numberOfCards;
  final List<String> cardPositions; // Significato di ogni posizione

  const TarotSpread({
    required this.name,
    required this.description,
    required this.numberOfCards,
    required this.cardPositions,
  });
}

// Modello per una singola Carta Estratta, che include il nome e la sua posizione nella stesa
class DrawnCard {
  final String name;
  final String position;

  DrawnCard({required this.name, required this.position});
}
