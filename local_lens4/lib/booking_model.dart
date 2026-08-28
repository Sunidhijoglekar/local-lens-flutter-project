import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String userId;
  final String guideId;
  final DateTime date;
  final String status; // e.g., 'pending', 'confirmed', 'completed'

  Booking({
    required this.id,
    required this.userId,
    required this.guideId,
    required this.date,
    required this.status,
  });

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>; // Correct data extraction
    return Booking(
      id: doc.id,
      userId: data['userId'],
      guideId: data['guideId'],
      date: (data['date'] as Timestamp).toDate(), // Convert Timestamp to DateTime
      status: data['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'guideId': guideId,
      'date': date,
      'status': status,
    };
  }
}
