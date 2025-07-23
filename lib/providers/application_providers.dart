// lib/providers/application_providers.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/eventbrite_event.dart';
import '../models/marketplace_models.dart'; // <-- IMPORT AGGIUNTO
import '../services/eventbrite_service.dart';
import '../services/firestore_service.dart';
import '../services/tarot_api_service.dart';
import '../services/tarot_deck_service.dart';

// --- Provider di Servizi e Autenticazione (invariati) ---
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final authStateChangesProvider = StreamProvider<User?>((ref) => ref.watch(firebaseAuthProvider).authStateChanges());
final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());
final tarotDeckServiceProvider = Provider<TarotDeckService>((ref) => TarotDeckService());
final tarotApiServiceProvider = Provider<TarotApiService>((ref) => TarotApiService());
final eventbriteServiceProvider = Provider<EventbriteService>((ref) => EventbriteService());

// --- Provider di Dati (Stream e Future) ---

final userStreamProvider = StreamProvider.autoDispose<DocumentSnapshot?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  if (authState.asData?.value != null) {
    final user = authState.asData!.value!;
    return ref.watch(firestoreServiceProvider).getUserStream(user.uid);
  }
  return Stream.value(null);
});

// Provider per i filtri del feed
final categoryFilterProvider = StateProvider<String?>((ref) => null);
final formatFilterProvider = StateProvider<String?>((ref) => null);

// Provider per gli eventi curati da noi (da Firestore)
final eventsStreamProvider = StreamProvider.autoDispose<QuerySnapshot>((ref) {
  final selectedCategory = ref.watch(categoryFilterProvider);
  final selectedFormat = ref.watch(formatFilterProvider);
  Query query = FirebaseFirestore.instance.collection('events');
  if (selectedCategory != null) {
    query = query.where('category', isEqualTo: selectedCategory);
  }
  if (selectedFormat != null) {
    query = query.where('format', isEqualTo: selectedFormat);
  }
  query = query.where('isPublished', isEqualTo: true);
  query = query.orderBy('eventDate', descending: false);
  return query.snapshots();
});

final eventbriteEventsProvider = FutureProvider.autoDispose<List<EventbriteEvent>>((ref) {
  final eventbriteService = ref.watch(eventbriteServiceProvider);
  return eventbriteService.fetchEvents(query: 'tarocchi');
});


// --- Provider per Corsi e Lezioni (invariati) ---
final coursesStreamProvider = StreamProvider.autoDispose<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance.collection('corsi').where('isPublished', isEqualTo: true).snapshots();
});

final lessonsStreamProvider = StreamProvider.autoDispose.family<QuerySnapshot, String>((ref, String courseId) {
  return FirebaseFirestore.instance.collection('corsi').doc(courseId).collection('lessons').orderBy('order').snapshots();
});

// --- Provider per Eventi Utente (invariati) ---
final registeredEventsStreamProvider = StreamProvider.autoDispose<QuerySnapshot>((ref) {
    final user = ref.watch(firebaseAuthProvider).currentUser;
    if (user != null) {
        return FirebaseFirestore.instance.collection('users').doc(user.uid).collection('registeredEvents').orderBy('eventDate', descending: false).snapshots();
    }
    return Stream.empty();
});

final eventRegistrationStatusProvider = StreamProvider.autoDispose.family<DocumentSnapshot, String>((ref, String eventId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final user = ref.watch(firebaseAuthProvider).currentUser;
  if (user != null) {
    return firestoreService.getRegistrationStatusStream(user.uid, eventId);
  }
  return Stream.empty();
});

// =================================================================
// NUOVA SEZIONE: PROVIDER PER IL MARKETPLACE
// =================================================================

final practitionersStreamProvider = StreamProvider.autoDispose<List<PractitionerProfile>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getPractitioners();
});

final servicesStreamProvider = StreamProvider.autoDispose.family<List<EsotericService>, String>((ref, practitionerId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getServicesForPractitioner(practitionerId);
});
