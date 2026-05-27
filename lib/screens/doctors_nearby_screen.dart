import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorsNearbyScreen extends StatelessWidget {
  const DoctorsNearbyScreen({super.key});

  static const Color _blueDark = Color(0xFF1A5F96);
  static const Color _blue     = Color(0xFF2A7FC1);

  Future<void> _openGoogleMaps(BuildContext context, String query) async {
    final uri = Uri.parse(
        "https://www.google.com/maps/search/${Uri.encodeComponent(query)}");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open Google Maps")),
        );
      }
    }
  }

  Widget _searchCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String query,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openGoogleMaps(context, query),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              Icon(Icons.open_in_new, color: Colors.grey.shade400, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FD),
      appBar: AppBar(
        title: const Text("Doctors Nearby"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _blueDark,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.local_hospital, color: Colors.white, size: 28),
                      SizedBox(width: 10),
                      Text("Find Nearby Doctors",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tap any option below to open Google Maps and find doctors near your current location.",
                    style: TextStyle(
                        fontSize: 13, color: Colors.white.withOpacity(0.85)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text("Search Nearby",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            _searchCard(
              context: context,
              icon: Icons.child_care,
              title: "Paediatrician",
              subtitle: "Child specialist doctors near you",
              query: "paediatrician near me",
              color: _blue,
            ),
            _searchCard(
              context: context,
              icon: Icons.vaccines,
              title: "Vaccination Centre",
              subtitle: "Clinics and centres offering child vaccines",
              query: "child vaccination centre near me",
              color: Colors.green.shade600,
            ),
            _searchCard(
              context: context,
              icon: Icons.local_hospital,
              title: "Children's Hospital",
              subtitle: "Hospitals with paediatric departments",
              query: "children's hospital near me",
              color: Colors.red.shade600,
            ),
            _searchCard(
              context: context,
              icon: Icons.medical_services,
              title: "General Physician",
              subtitle: "General doctors for basic child health",
              query: "general physician near me",
              color: Colors.orange.shade700,
            ),
            _searchCard(
              context: context,
              icon: Icons.local_pharmacy,
              title: "Pharmacy",
              subtitle: "Nearby pharmacies for medicines and vaccines",
              query: "pharmacy near me",
              color: Colors.teal.shade600,
            ),

            const SizedBox(height: 24),

            // Tips
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.05))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Tips for Doctor Visits",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...[
                    ["📋", "Carry your child's vaccination record book to every visit."],
                    ["📏", "Note your child's height and weight before the visit — use Valar's growth tracker."],
                    ["⏰", "Book appointments in advance — paediatricians tend to be busy in the mornings."],
                    ["💉", "Always ask the doctor to check your child's vaccination status at every visit."],
                    ["🏥", "For overdue vaccines, visit a government PHC (Primary Health Centre) — most vaccines are free."],
                  ].map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tip[0], style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(tip[1],
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey.shade700)),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}