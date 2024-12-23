import 'package:flutter/material.dart';
import 'package:mediza_admin/clinicmanagment.dart';
import 'package:mediza_admin/main.dart';
import 'package:mediza_admin/specializatiomanagment.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            // Button for Clinics
            DashboardButton(
              label: 'Manage Clinics',
              icon: Icons.local_hospital,
              onPressed: () {
                // Navigate to Clinics management page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClinicManagment()),
                );
              },
            ),
            // Button for Staff
            DashboardButton(
              label: 'Manage Staff',
              icon: Icons.people,
              onPressed: () {
                // Navigate to Staff management page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Placeholder()),
                );
              },
            ),
            // Button for Specializations
            DashboardButton(
              label: 'Manage Specializations',
              icon: Icons.medical_services,
              onPressed: () {
                // Navigate to Specializations management page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SpecializationManagementPage()),
                );
              },
            ),
            // Add more buttons for other features here
          ],
        ),
      ),
    );
  }
}

class DashboardButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const DashboardButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
