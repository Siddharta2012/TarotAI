// lib/models/eventbrite_event.dart

/// Rappresenta un singolo evento recuperato dall'API di Eventbrite.
/// Questo modello aiuta a gestire i dati in modo strutturato e sicuro.
class EventbriteEvent {
  final String name;
  final String url;
  final String imageUrl;
  final DateTime? startDate;

  EventbriteEvent({
    required this.name,
    required this.url,
    required this.imageUrl,
    this.startDate,
  });

  /// Factory constructor per creare un'istanza di EventbriteEvent da un JSON.
  /// Questo metodo si occupa di estrarre i dati dalla mappa restituita dall'API
  /// e di gestire i casi in cui alcuni campi potrebbero essere nulli.
  factory EventbriteEvent.fromJson(Map<String, dynamic> json) {
    // Estraiamo la data e la parsiamo in un oggetto DateTime.
    // Usiamo un blocco try-catch per evitare crash se il formato della data non è valido.
    DateTime? parsedDate;
    if (json['start']?['local'] != null) {
      try {
        parsedDate = DateTime.parse(json['start']['local']);
      } catch (e) {
        print('Formato data non valido per l\'evento: ${json['name']?['text']}');
        parsedDate = null; // Se il formato non è valido, lasciamo la data nulla.
      }
    }

    return EventbriteEvent(
      name: json['name']?['text'] ?? 'Senza nome',
      url: json['url'] ?? '',
      // Eventbrite può avere un'immagine o no, gestiamo il caso in cui 'logo' o 'original' siano null.
      imageUrl: json['logo']?['original']?['url'] ?? '',
      startDate: parsedDate,
    );
  }
}