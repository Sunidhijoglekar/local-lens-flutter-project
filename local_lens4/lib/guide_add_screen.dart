import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class GuideAddScreen extends StatefulWidget {
  const GuideAddScreen({super.key});

  @override
  _GuideAddScreenState createState() => _GuideAddScreenState();
}

class _GuideAddScreenState extends State<GuideAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  Future<void> _submitGuide() async {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text.trim();
      String id = Uuid().v4(); // Use a unique ID
      String bio = _bioController.text.trim();
      String imageUrl = _imageUrlController.text.trim();
      double latitude = double.tryParse(_latitudeController.text.trim()) ?? 0.0;
      double longitude = double.tryParse(_longitudeController.text.trim()) ?? 0.0;

      // URL validation
      if (Uri.tryParse(imageUrl)?.hasAbsolutePath ?? false) {
        try {
          // Store the guide with GeoPoint (latitude, longitude)
          await FirebaseFirestore.instance.collection('guides').doc(id).set({
            'name': name,
            'bio': bio,
            'imageUrl': imageUrl,
            'location': GeoPoint(latitude, longitude), // Adding location
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Guide added successfully!')),
          );

          // Reset form
          _formKey.currentState!.reset();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid image URL')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Guide'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Guide Details',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter a name' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bioController,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.info_outline),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter a bio' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Image URL',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.image),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter an image URL' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _latitudeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter a latitude' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _longitudeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter a longitude' : null,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _submitGuide,
                    icon: const Icon(Icons.add),
                    label: const Text('Submit Guide'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}