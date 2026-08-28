import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'guide_model.dart';
import 'payment_service.dart';
import 'package:local_lens4/booking_confirmation_screen.dart';

class BookingScreen extends StatefulWidget {
  final Guide guide;
  final User user;

  const BookingScreen({super.key, required this.guide, required this.user});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isLoading = false;

  Future<void> pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  Future<void> bookGuide() async {
    if (selectedDate == null || selectedTime == null) {
      showSnackBar("Please select both date and time.");
      return;
    }

    // Check if the selected date is in the past
    if (selectedDate!.isBefore(DateTime.now())) {
      showSnackBar("The selected date cannot be in the past.");
      return;
    }

    setState(() => isLoading = true);

    try {
      // Start payment
      await PaymentService.processPayment();

      // Format booking time
      final bookingDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      ).toUtc(); // Save UTC time for consistency

      // Save to Firestore
      await FirebaseFirestore.instance.collection('bookings').add({
        'guideId': widget.guide.id,
        'guideName': widget.guide.name,
        'userId': widget.user.uid,
        'userEmail': widget.user.email,
        'dateTime': bookingDateTime.toIso8601String(),
        'createdAt': Timestamp.now(),
      });

      showSnackBar("Booking successful!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BookingConfirmationScreen()),
      );
    } catch (e) {
      showSnackBar("Booking failed: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

 @override
Widget build(BuildContext context) {
  final guide = widget.guide;

  return Scaffold(
    appBar: AppBar(
      title: Text("Book ${guide.name}"),
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.white,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          guide.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    guide.bio,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.calendar_today),
            onPressed: pickDate,
            label: Text(selectedDate == null
                ? "Pick a date"
                : "Date: ${selectedDate!.toLocal().toString().split(' ')[0]}"),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            icon: const Icon(Icons.access_time),
            onPressed: pickTime,
            label: Text(selectedTime == null
                ? "Pick a time"
                : "Time: ${selectedTime!.format(context)}"),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
            FilledButton.icon(
              icon: const Icon(Icons.payment),
              onPressed: bookGuide,
              label: const Text("Confirm & Pay"),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
        ],
      ),
    ),
  );
}
}