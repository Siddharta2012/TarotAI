// lib/services/tarot_api_service.dart

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class TarotApiService {
  // Carichiamo la chiave API e l'URL base qui, una sola volta.
  final String? _apiKey = dotenv.env['GEMINI_API_KEY'];
  final String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  // Un unico metodo per ottenere l'interpretazione, riutilizzabile ovunque.
  Future<String> getInterpretation(String prompt) async {
    if (_apiKey == null) {
      throw Exception('API Key non trovata. Controlla il file .env');
    }

    final url = Uri.parse('$_baseUrl?key=$_apiKey');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': [{'parts': [{'text': prompt}]}]
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Aggiungiamo un controllo per assicurarci che la risposta abbia il formato atteso
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          return data['candidates'][0]['content']['parts'][0]['text'];
        } else {
          throw Exception('Formato della risposta API non valido.');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Errore API (${response.statusCode}): ${errorData['error']['message']}');
      }
    } catch (e) {
      // Rilanciamo l'eccezione per poterla gestire nella UI
      rethrow;
    }
  }
}