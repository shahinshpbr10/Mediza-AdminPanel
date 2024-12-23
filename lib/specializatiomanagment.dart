import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class SpecializationManagementPage extends StatefulWidget {
  const SpecializationManagementPage({super.key});

  @override
  _SpecializationManagementPageState createState() =>
      _SpecializationManagementPageState();
}

class _SpecializationManagementPageState
    extends State<SpecializationManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // List to store fetched specializations
  List<Map<String, String>> specializations = [];

  // Fetch specializations from Firestore
  Future<void> _fetchSpecializations() async {
    try {
      print("Fetching specializations from Firestore...");

      DocumentSnapshot snapshot = await _firestore
          .collection('settings') // settings collection
          .doc('specializations') // specialization document
          .get();

      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        var specializationList = data['specializations'] as List<dynamic>;

        print("Specializations found: ${specializationList.length}");

        // Fetch icon URLs for each specialization from Firebase Storage
        List<Map<String, String>> loadedSpecializations = [];

        for (var spec in specializationList) {
          String name = spec['name'] ?? '';
          String iconUrl = spec['iconUrl'] ?? '';

          print("Specialization name: $name, Icon URL: $iconUrl");

          loadedSpecializations.add({
            'name': name,
            'iconUrl': iconUrl,
          });
        }

        // Update the state with fetched specializations
        setState(() {
          specializations = loadedSpecializations;
        });
      } else {
        print("No specializations found in Firestore.");
      }
    } catch (e) {
      // Handle any errors
      print("Error fetching specializations: $e");
    }
  }



  @override
  void initState() {
    super.initState();
    // Fetch specializations when the page loads
    _fetchSpecializations();
  }

  // Widget to display specialization items
  Widget _buildSpecializationItem(Map<String, String> specialization) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: ListTile(
        leading: specialization['iconUrl'] != ''
            ? Image.network(specialization['iconUrl']!, width: 40, height: 40)
            : const Icon(Icons.medical_services),
        title: Text(specialization['name'] ?? 'No Name'),
        onTap: () {
          // Handle on tap, maybe navigate or show more details
          print("Tapped on specialization: ${specialization['name']}");
        },
      ),
    );
  }

  // Method to show a dialog for adding a new specialization
  void _showAddSpecializationDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController iconUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Specialization'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Specialization Name'),
              ),
              TextField(
                controller: iconUrlController,
                decoration: const InputDecoration(labelText: 'Icon URL'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String name = nameController.text.trim();
                String iconUrl = iconUrlController.text.trim();

                if (name.isEmpty || iconUrl.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                // Log values before adding
                print("Adding new specialization: Name = $name, Icon URL = $iconUrl");

                try {
                  // Add new specialization to Firestore
                  await _firestore
                      .collection('settings')
                      .doc('specializations') // Target the specialization document
                      .update({
                    'specializations': FieldValue.arrayUnion([
                      {'name': name, 'iconUrl': iconUrl}
                    ]),
                  });

                  // Close the dialog and reload the specializations
                  Navigator.pop(context);
                  _fetchSpecializations();
                } catch (e) {
                  print("Error adding specialization: $e");
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Specializations'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: specializations.isEmpty
            ? const Center(child: Text('There is no specialization'))
            : ListView.builder(
          itemCount: specializations.length,
          itemBuilder: (context, index) {
            return _buildSpecializationItem(specializations[index]);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSpecializationDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
