// lib/models/marketplace_models.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class PractitionerProfile {
  final String id;
  final String displayName;
  final String bio;
  final String photoUrl;
  final List<String> specializations;

  PractitionerProfile({
    required this.id,
    required this.displayName,
    required this.bio,
    required this.photoUrl,
    required this.specializations,
  });

  factory PractitionerProfile.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PractitionerProfile(
      id: doc.id,
      displayName: data['displayName'] ?? 'N/D',
      bio: data['bio'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      specializations: List<String>.from(data['specializations'] ?? []),
    );
  }
}

class EsotericService {
  final String id;
  final String title;
  final String description;
  final double price;
  final String type;

  EsotericService({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.type,
  });

  factory EsotericService.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return EsotericService(
      id: doc.id,
      title: data['title'] ?? 'Servizio senza titolo',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      type: data['type'] ?? 'generico',
    );
  }
}