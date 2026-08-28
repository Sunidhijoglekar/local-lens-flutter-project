import 'package:cloud_firestore/cloud_firestore.dart';

class Guide {
  final String id;
  final String name;
  final String bio;
  final String imageUrl;
  final double latitude;
  final double longitude;

  Guide({
    required this.id,
    required this.name,
    required this.bio,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
  });

  // Factory method to create a Guide object from Firestore document
  factory Guide.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Extracting latitude and longitude from Firestore GeoPoint
    final geoPoint = data['location'] as GeoPoint?;
    final latitude = geoPoint?.latitude ?? 0.0;
    final longitude = geoPoint?.longitude ?? 0.0;

    return Guide(
      id: doc.id,
      name: data['name'] ?? '',
      bio: data['bio'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      latitude: latitude,
      longitude: longitude,
    );
  }
}
