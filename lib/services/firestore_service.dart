import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/marketplace_models.dart'; // <-- IMPORT AGGIUNTO

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Funzioni Utente ---
  Future<void> createNewUser(User user) async {
    final userRef = _db.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      await userRef.set({
        'email': user.email ?? '',
        'displayName': user.displayName ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'tokens': 10,
      });
    }
  }

  Stream<DocumentSnapshot> getUserStream(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  // --- Funzioni Gettoni ---
  Future<bool> hasEnoughTokens(String uid, int amount) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      final currentTokens = data['tokens'] ?? 0;
      return currentTokens >= amount;
    }
    return false;
  }

  Future<void> deductTokens(String uid, int amount) async {
    final userRef = _db.collection('users').doc(uid);
    return userRef.update({'tokens': FieldValue.increment(-amount)});
  }
  
  Future<void> addDeveloperTokens(String uid) async {
    final userRef = _db.collection('users').doc(uid);
    return userRef.set(
      {'tokens': FieldValue.increment(10)},
      SetOptions(merge: true),
    );
  }

  // --- Funzioni Eventi ---
  Future<void> registerUserForEvent(String userId, DocumentSnapshot eventDoc) async {
    final eventData = eventDoc.data() as Map<String, dynamic>;
    
    await _db
        .collection('users')
        .doc(userId)
        .collection('registeredEvents')
        .doc(eventDoc.id)
        .set({
          'title': eventData['title'] ?? 'N/D',
          'eventDate': eventData['eventDate'],
          'hostName': eventData['hostName'] ?? 'N/D',
          'originalEventId': eventDoc.id,
        });
  }

  Future<void> unregisterUserFromEvent(String userId, String eventId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('registeredEvents')
        .doc(eventId)
        .delete();
  }

  Stream<DocumentSnapshot> getRegistrationStatusStream(String userId, String eventId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('registeredEvents')
        .doc(eventId)
        .snapshots();
  }

  // =================================================================
  // NUOVA SEZIONE: FUNZIONI PER IL MARKETPLACE
  // =================================================================

  /// Fornisce uno stream con la lista di tutti gli operatori.
  Stream<List<PractitionerProfile>> getPractitioners() {
    return _db.collection('practitioners').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => PractitionerProfile.fromFirestore(doc)).toList();
    });
  }

  /// Fornisce uno stream con i servizi di un operatore specifico.
  Stream<List<EsotericService>> getServicesForPractitioner(String practitionerId) {
    return _db
        .collection('practitioners')
        .doc(practitionerId)
        .collection('services')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => EsotericService.fromFirestore(doc)).toList();
    });
  }
}
