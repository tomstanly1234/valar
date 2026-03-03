import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'growth_analysis_screen.dart';

class ChildAssessmentScreen extends StatefulWidget {
  final String childId;
  final String childName;
  final String gender;

  const ChildAssessmentScreen({
    super.key,
    required this.childId,
    required this.childName,
    required this.gender,
  });

  @override
  State<ChildAssessmentScreen> createState() =>
      _ChildAssessmentScreenState();
}

class _ChildAssessmentScreenState extends State<ChildAssessmentScreen> {
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final monthController = TextEditingController();

  @override
  void dispose() {
    weightController.dispose();
    heightController.dispose();
    monthController.dispose();
    super.dispose();
  }

  Future<void> submitData() async {
    // ── Validate inputs ──────────────────────────────────────────────────
    if (monthController.text.isEmpty ||
        weightController.text.isEmpty ||
        heightController.text.isEmpty) {
      _showSnack("Please fill all fields.");
      return;
    }

    final int month = int.tryParse(monthController.text.trim()) ?? -1;
    final double weight = double.tryParse(weightController.text.trim()) ?? -1;
    final double height = double.tryParse(heightController.text.trim()) ?? -1;

    if (month < 0 || month > 60) {
      _showSnack("Age must be between 0 and 60 months.");
      return;
    }
    if (weight <= 0 || weight > 50) {
      _showSnack("Please enter a valid weight (kg).");
      return;
    }
    if (height <= 0 || height > 150) {
      _showSnack("Please enter a valid height (cm).");
      return;
    }

    // ── Show loading dialog immediately so user gets instant feedback ────
    _showLoadingDialog();

    try {
      // Save to Firestore
      await FirestoreService.saveGrowthRecord(
        widget.childId,
        month,
        weight,
        height,
      );

      // Fetch all records WHILE the loading dialog is already showing
      final snapshot =
          await FirestoreService.getGrowthRecords(widget.childId);
      final records = snapshot.docs.map((doc) => doc.data()).toList()
        ..sort((a, b) =>
            (a["month"] as num).compareTo(b["month"] as num));

      if (!mounted) return;

      // Dismiss loading dialog
      Navigator.pop(context);

      // Navigate — pass records directly, no second fetch needed
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GrowthAnalysisScreen(
            childId: widget.childId,
            childName: widget.childName,
            gender: widget.gender,
            initialRecords: records, // ✅ pre-loaded, screen shows instantly
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // dismiss dialog on error
        _showSnack("Failed to save: $e");
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text("Saving & analysing..."),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget inputCard(
      String label, TextEditingController controller, String hint) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          hintText: hint,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FD),
      appBar: AppBar(
        title: Text(widget.childName),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            Text(
              "Enter Growth Data",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Record measurements to track your child's growth progress.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            inputCard("Age in Months (0–60)", monthController, "e.g. 12"),
            inputCard("Weight (kg)", weightController, "e.g. 9.5"),
            inputCard("Height (cm)", heightController, "e.g. 75.0"),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: submitData,
                icon: const Icon(Icons.bar_chart),
                label: const Text(
                  "Analyze Growth",
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}