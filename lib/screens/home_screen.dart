// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'child_assessment_screen.dart';
import 'growth_analysis_screen.dart';
import 'vaccination_screen.dart';
import 'doctors_nearby_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const int _maxChildren = 10;
  static const Color _brandBlue = Color(0xFF2A7FC1);
  static const Color _green     = Color(0xFF2E7D32);

  void _showAddChildDialog(BuildContext context, int currentCount) {
    if (currentCount >= _maxChildren) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Maximum of $_maxChildren children reached."),
        backgroundColor: Colors.red.shade700,
      ));
      return;
    }

    final nameController = TextEditingController();
    String selectedGender = "Boy";
    DateTime? selectedDob;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text("Add Child"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // ── Name ────────────────────────────────────────────────
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: "Child Name",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── Gender ───────────────────────────────────────────────
              DropdownButtonFormField<String>(
                value: selectedGender,
                items: const [
                  DropdownMenuItem(value: "Boy",  child: Text("Boy")),
                  DropdownMenuItem(value: "Girl", child: Text("Girl")),
                ],
                onChanged: (v) =>
                    setDialogState(() => selectedGender = v!),
                decoration: InputDecoration(
                  labelText: "Gender",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── Date of Birth picker ─────────────────────────────────
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(DateTime.now().year - 18),
                    lastDate: DateTime.now(),
                    helpText: "Select Date of Birth",
                  );
                  if (picked != null) {
                    setDialogState(() => selectedDob = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cake_outlined,
                          color: Color(0xFF2A7FC1), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          selectedDob == null
                              ? "Date of Birth (for vaccines)"
                              : "${selectedDob!.day}/${selectedDob!.month}/${selectedDob!.year}",
                          style: TextStyle(
                            fontSize: 14,
                            color: selectedDob == null
                                ? Colors.grey.shade500
                                : Colors.black87,
                          ),
                        ),
                      ),
                      Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey.shade400),
                    ],
                  ),
                ),
              ),

              // DOB optional note
              const SizedBox(height: 6),
              const Text(
                "Date of birth is optional but enables automatic vaccine due-date calculation.",
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                try {
                  await FirestoreService.addChild(
                      name, selectedGender, selectedDob);
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text("My Children",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.local_hospital,
                color: Color(0xFFC62828)),
            tooltip: "Doctors Nearby",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const DoctorsNearbyScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () async => await AuthService.logout(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirestoreService.getChildren(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Stack(
              children: [
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.child_care, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text("No children added yet.",
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey)),
                      SizedBox(height: 8),
                      Text("Tap + to add your first child.",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 16, right: 16,
                  child: FloatingActionButton(
                    backgroundColor: Colors.pinkAccent,
                    onPressed: () => _showAddChildDialog(context, 0),
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            );
          }

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final child     = docs[i];
                  final gender    = child["gender"] as String;
                  final childId   = child.id;
                  final childName = child["name"] as String;

                  // ── Parse DOB if stored ───────────────────────────
                  DateTime? dob;
                  if (child.data()["dob"] != null) {
                    dob = (child.data()["dob"] as Timestamp).toDate();
                  }

                  // Age in months from DOB (for vaccines)
                  final ageMonths = dob != null
                      ? FirestoreService.ageInMonthsFromDob(dob)
                      : (child.data()["lastAgeMonths"] as num?)
                              ?.toInt() ??
                          0;

                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // ── Avatar + name ─────────────────────────
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: gender == "Boy"
                                    ? Colors.blue.shade100
                                    : Colors.pink.shade100,
                                child: Icon(
                                  gender == "Boy"
                                      ? Icons.boy
                                      : Icons.girl,
                                  color: gender == "Boy"
                                      ? Colors.blue
                                      : Colors.pinkAccent,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(childName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17)),
                                    Text(
                                      dob != null
                                          ? "$gender  •  Age: ${_ageString(ageMonths)}"
                                          : gender,
                                      style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              // Edit child
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    size: 20, color: Color(0xFF2A7FC1)),
                                tooltip: "Edit child",
                                onPressed: () => _showEditChildDialog(
                                    context, childId, childName,
                                    gender, dob),
                              ),
                              // Delete child
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    size: 20, color: Colors.redAccent),
                                tooltip: "Delete child",
                                onPressed: () => _confirmDeleteChild(
                                    context, childId, childName),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),
                          const Divider(height: 1),
                          const SizedBox(height: 12),

                          // ── Action buttons ────────────────────────
                          Row(
                            children: [
                              Expanded(child: _actionButton(
                                icon: Icons.bar_chart,
                                label: "Growth",
                                color: _brandBlue,
                                onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) =>
                                    GrowthAnalysisScreen(
                                      childId: childId,
                                      childName: childName,
                                      gender: gender,
                                    ))),
                              )),
                              const SizedBox(width: 8),
                              Expanded(child: _actionButton(
                                icon: Icons.vaccines,
                                label: "Vaccines",
                                color: _green,
                                onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) =>
                                    VaccinationScreen(
                                      childId: childId,
                                      childName: childName,
                                      gender: gender,
                                      dob: dob,
                                    ))),
                              )),
                              const SizedBox(width: 8),
                              Expanded(child: _actionButton(
                                icon: Icons.add_circle_outline,
                                label: "Add Data",
                                color: Colors.pinkAccent,
                                onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) =>
                                    ChildAssessmentScreen(
                                      childId: childId,
                                      childName: childName,
                                      gender: gender,
                                    ))),
                              )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // FAB
              Positioned(
                bottom: 16, right: 16,
                child: FloatingActionButton(
                  backgroundColor: docs.length >= _maxChildren
                      ? Colors.grey
                      : Colors.pinkAccent,
                  onPressed: () =>
                      _showAddChildDialog(context, docs.length),
                  tooltip: docs.length >= _maxChildren
                      ? "Limit of $_maxChildren children reached"
                      : "Add child",
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Edit child dialog ────────────────────────────────────────────────

  void _showEditChildDialog(
    BuildContext context,
    String childId,
    String currentName,
    String currentGender,
    DateTime? currentDob,
  ) {
    final nameController =
        TextEditingController(text: currentName);
    String selectedGender = currentGender;
    DateTime? selectedDob  = currentDob;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text("Edit Child"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: "Child Name",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Gender
              DropdownButtonFormField<String>(
                value: selectedGender,
                items: const [
                  DropdownMenuItem(value: "Boy",  child: Text("Boy")),
                  DropdownMenuItem(value: "Girl", child: Text("Girl")),
                ],
                onChanged: (v) =>
                    setDialogState(() => selectedGender = v!),
                decoration: InputDecoration(
                  labelText: "Gender",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // DOB picker
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDob ?? DateTime.now(),
                    firstDate:
                        DateTime(DateTime.now().year - 18),
                    lastDate: DateTime.now(),
                    helpText: "Select Date of Birth",
                  );
                  if (picked != null) {
                    setDialogState(() => selectedDob = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cake_outlined,
                          color: Color(0xFF2A7FC1), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          selectedDob == null
                              ? "Date of Birth (tap to set)"
                              : "${selectedDob!.day}/${selectedDob!.month}/${selectedDob!.year}",
                          style: TextStyle(
                            fontSize: 14,
                            color: selectedDob == null
                                ? Colors.grey.shade500
                                : Colors.black87,
                          ),
                        ),
                      ),
                      if (selectedDob != null)
                        GestureDetector(
                          onTap: () =>
                              setDialogState(() => selectedDob = null),
                          child: const Icon(Icons.clear,
                              size: 18, color: Colors.grey),
                        )
                      else
                        Icon(Icons.calendar_today,
                            size: 16, color: Colors.grey.shade400),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                try {
                  await FirestoreService.updateChild(
                      childId, name, selectedGender, selectedDob);
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text(e.toString())));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A7FC1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  // ── Delete child confirmation ──────────────────────────────────────────

  void _confirmDeleteChild(
      BuildContext context, String childId, String childName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Child"),
        content: Text(
            "Are you sure you want to delete $childName and all their "
            "growth and vaccination records? This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirestoreService.deleteChild(childId);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  String _ageString(int months) {
    if (months < 12) return "${months}m";
    final y = months ~/ 12;
    final m = months % 12;
    if (m == 0) return "${y}y";
    return "${y}y ${m}m";
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}