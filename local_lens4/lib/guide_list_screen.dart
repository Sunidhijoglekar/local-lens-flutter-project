import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'guide_model.dart';
import 'booking_screen.dart';
import 'guide_add_screen.dart';
import 'map_screen.dart';
import 'payment_service.dart';

class GuideListScreen extends StatelessWidget {
  final User user;
  final bool isDarkMode;
  final Function(bool) onThemeChanged;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  GuideListScreen({
    super.key,
    required this.user,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  Future<List<Guide>> getGuides() async {
    final snapshot = await _db.collection('guides').get();
    return snapshot.docs.map((doc) => Guide.fromFirestore(doc)).toList();
  }

  void _startPayment(BuildContext context) async {
    try {
      await PaymentService.processPayment();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment successful')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment failed: $e')));
    }
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  // Delete guide from Firestore
  Future<void> _deleteGuide(String guideId, BuildContext context) async {
    try {
      await _db.collection('guides').doc(guideId).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guide deleted successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete guide: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Guides"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.feedback_outlined),
              title: const Text('Feedback'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feedback feature coming soon!')));
              },
            ),
            SwitchListTile(
              secondary: const Icon(Icons.brightness_6),
              title: const Text('Dark Mode'),
              value: isDarkMode,
              onChanged: onThemeChanged,
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log Out'),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Guide>>(
        future: getGuides(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No guides available.'));
          }

          final guides = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: guides.length,
            itemBuilder: (context, index) {
              final guide = guides[index];

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundImage: guide.imageUrl.isNotEmpty
                              ? NetworkImage(guide.imageUrl)
                              : null,
                          child: guide.imageUrl.isEmpty
                              ? const Icon(Icons.person, size: 30)
                              : null,
                        ),
                        title: Text(
                          guide.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          guide.bio,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookingScreen(guide: guide, user: user),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MapScreen(guides: guides), // Pass the list of guides
                                ),
                              );
                            },
                            icon: const Icon(Icons.map),
                            label: const Text("View on Map"),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteGuide(guide.id, context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => GuideAddScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Guide"),
      ),
    );
  }
}
