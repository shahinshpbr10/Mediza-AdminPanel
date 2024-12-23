import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,  // Use platform-specific options
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mediza Admin App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin App - Clinic Management'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('clinics').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching clinics.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No clinics found.'));
          }

          final clinics = snapshot.data!.docs;

          return ListView.builder(
            itemCount: clinics.length,
            itemBuilder: (context, index) {
              final clinic = clinics[index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: clinic['profilePhoto'] != null
                      ? Image.network(
                    clinic['profilePhoto'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                      : const Icon(Icons.local_hospital),
                  title: Text(clinic['name'] ?? 'No Name'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Address: ${clinic['address']}"),
                      Text("Email: ${clinic['email']}"),
                      Text("Phone: ${clinic['phone']}"),
                      Text("Approval Status: ${clinic['approvalStatus']}"),
                      const SizedBox(height: 5),
                      // Dropdown to change approval status
                      Row(
                        children: [
                          const Text('Change Status:'),
                          const SizedBox(width: 10),
                          DropdownButton<String>(
                            value: clinic['approvalStatus'],
                            items: const [
                              DropdownMenuItem(
                                value: 'approved',
                                child: Text('Approved'),
                              ),
                              DropdownMenuItem(
                                value: 'rejected',
                                child: Text('Rejected'),
                              ),
                              DropdownMenuItem(
                                value: 'pending',
                                child: Text('Pending'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                _updateApprovalStatus(clinic.id, value);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _editClinicDetails(context, clinic);
                            },
                            child: const Text('Edit Clinic'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              _deleteClinic(clinic.id);
                            },
                            child: const Text('Delete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
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
    );
  }

  // Function to update the approval status
  void _updateApprovalStatus(String clinicId, String newStatus) async {
    try {
      await _firestore.collection('clinics').doc(clinicId).update({
        'approvalStatus': newStatus,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Approval status updated to $newStatus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update status.')),
      );
    }
  }

  // Function to edit clinic details
  Future<void> _editClinicDetails(BuildContext context, DocumentSnapshot clinic) async {
    final TextEditingController nameController = TextEditingController(text: clinic['name']);
    final TextEditingController addressController = TextEditingController(text: clinic['address']);
    final TextEditingController emailController = TextEditingController(text: clinic['email']);
    final TextEditingController phoneController = TextEditingController(text: clinic['phone']);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Clinic Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Clinic Name'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isEmpty || addressController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill out all fields')),
                  );
                  return;
                }
                await _firestore.collection('clinics').doc(clinic.id).update({
                  'name': nameController.text,
                  'address': addressController.text,
                  'email': emailController.text,
                  'phone': phoneController.text,
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Clinic details updated')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Function to delete a clinic
  Future<void> _deleteClinic(String clinicId) async {
    try {
      await _firestore.collection('clinics').doc(clinicId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clinic deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete clinic.')),
      );
    }
  }
}
