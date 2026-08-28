import 'package:cloud_firestore/cloud_firestore.dart';
import 'booking_model.dart'; // Import the Booking class



class BookingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createBooking(Booking booking) async {
    try {
      await _db.collection('bookings').add(booking.toMap());
    } catch (e) {
      print("Error creating booking: $e");
    }
  }

  Future<List<Booking>> getBookings(String userId) async {
    final snapshot = await _db.collection('bookings')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
  }
}
