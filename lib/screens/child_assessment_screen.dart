// lib/screens/child_assessment_screen.dart

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
  final monthController  = TextEditingController();

  // Toggle: enter age as months or years
  bool _useYears = false;

  @override
  void dispose() {
    weightController.dispose();
    heightController.dispose();
    monthController.dispose();
    super.dispose();
  }

  // Convert to months regardless of input mode
  int? _ageInMonths() {
    final raw = int.tryParse(monthController.text.trim());
    if (raw == null) return null;
    return _useYears ? raw * 12 : raw;
  }

  Future<void> submitData() async {
    if (monthController.text.isEmpty ||
        weightController.text.isEmpty ||
        heightController.text.isEmpty) {
      _showSnack("Please fill all fields.");
      return;
    }

    final int? month = _ageInMonths();
    final double weight =
        double.tryParse(weightController.text.trim()) ?? -1;
    final double height =
        double.tryParse(heightController.text.trim()) ?? -1;

    if (month == null || month < 0 || month > 216) {
      _showSnack(_useYears
          ? "Age must be between 0 and 18 years."
          : "Age must be between 0 and 216 months (18 years).");
      return;
    }
    if (weight <= 0 || weight > 150) {
      _showSnack("Please enter a valid weight (kg).");
      return;
    }
    if (height <= 0 || height > 220) {
      _showSnack("Please enter a valid height (cm).");
      return;
    }

    _showLoadingDialog();

    try {
      await FirestoreService.saveGrowthRecord(
          widget.childId, month, weight, height);

      final snapshot =
          await FirestoreService.getGrowthRecords(widget.childId);
      final records = snapshot.docs.map((doc) => doc.data()).toList()
        ..sort((a, b) =>
            (a["month"] as num).compareTo(b["month"] as num));

      if (!mounted) return;
      Navigator.pop(context); // dismiss dialog

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GrowthAnalysisScreen(
            childId: widget.childId,
            childName: widget.childName,
            gender: widget.gender,
            initialRecords: records,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showSnack("Failed to save: $e");
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(children: [
          CircularProgressIndicator(),
          SizedBox(width: 20),
          Text("Saving & analysing..."),
        ]),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _inputCard(
      String label, TextEditingController ctrl, String hint) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.05))
        ],
      ),
      child: TextField(
        controller: ctrl,
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
              "Record measurements to track growth from birth to 18 years.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // ── Age input toggle ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 6,
                      color: Colors.black.withOpacity(0.05))
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _useYears = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_useYears
                              ? const Color(0xFF2A7FC1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            "Enter in Months",
                            style: TextStyle(
                              color: !_useYears
                                  ? Colors.white
                                  : Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _useYears = true),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _useYears
                              ? const Color(0xFF2A7FC1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            "Enter in Years",
                            style: TextStyle(
                              color: _useYears
                                  ? Colors.white
                                  : Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _inputCard(
              _useYears
                  ? "Age in Years (0–18)"
                  : "Age in Months (0–216)",
              monthController,
              _useYears ? "e.g. 5" : "e.g. 60",
            ),
            _inputCard("Weight (kg)", weightController, "e.g. 18.5"),
            _inputCard("Height (cm)", heightController, "e.g. 110.0"),

            const SizedBox(height: 8),

            // Helper note
            Text(
              _useYears
                  ? "Tip: 18 years = 216 months"
                  : "Tip: You can also switch to entering age in years above.",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: submitData,
                icon: const Icon(Icons.bar_chart),
                label: const Text("Analyze Growth",
                    style: TextStyle(fontSize: 18)),
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