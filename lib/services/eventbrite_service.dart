// lib/services/eventbrite_service.dart

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // ** LA CORREZIONE È QUI **
import 'package:http/http.dart' as http;
import '../models/eventbrite_event.dart';

class EventbriteService {
  final String? _apiKey = dotenv.env['EVENTBRITE_API_KEY'];
  // NOTA: Abbiamo rimosso il path /v3 da qui per usarlo nel costruttore Uri
  final String _authority = 'www.eventbriteapi.com';

  /// Recupera una lista di eventi da Eventbrite in base a una query.
  ///
  /// Restituisce un `Future` che si risolve in una `List<EventbriteEvent>`.
  /// Lancia un'eccezione in caso di errori di rete o API.
  Future<List<EventbriteEvent>> fetchEvents({required String query}) async {
    if (_apiKey == null) {
      throw Exception('Chiave API di Eventbrite non trovata nel file .env');
    }

    // Usiamo il costruttore Uri.https per creare l'URL in modo robusto.
    // Questo metodo gestisce correttamente la formattazione di path e parametri,
    // eliminando gli errori legati a slash mancanti o in eccesso.
    final url = Uri.https(
      _authority,
      '/v3/events/search/', // Il percorso corretto per l'API di ricerca
      {
        'q': query,
        'location.address': 'italia',
        'sort_by': 'date',
        'expand': 'logo',
      },
    );

    try {
      // Stampiamo l'URL finale per un controllo nel log di debug
      print('EventbriteService: Chiamata a URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List eventsJson = data['events'];

        return eventsJson
            .map((json) => EventbriteEvent.fromJson(json))
            .toList();
      } else {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['error_description'] ?? 'Errore sconosciuto da Eventbrite';
        throw Exception('Errore Eventbrite (${response.statusCode}): $errorMessage');
      }
    } catch (e) {
      print('Errore generico in EventbriteService: $e');
      rethrow;
    }
  }
}
