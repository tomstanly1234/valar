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

  // Toggle between months and years
  bool _useYears = false;

  static const Color _brandBlue = Color(0xFF2A7FC1);

  @override
  void dispose() {
    weightController.dispose();
    heightController.dispose();
    monthController.dispose();
    super.dispose();
  }

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

    // ── Height regression check ───────────────────────────────────────
    // Fetch existing records to validate height isn't less than
    // the most recent previous month
    _showLoadingDialog();
    try {
      final snapshot =
          await FirestoreService.getGrowthRecords(widget.childId);
      final existing = snapshot.docs.map((d) => d.data()).toList()
        ..sort((a, b) =>
            (a["month"] as num).compareTo(b["month"] as num));

      // Find records from months BEFORE the one being entered
      final previousRecords = existing
          .where((r) => (r["month"] as num).toInt() < month)
          .toList();

      if (previousRecords.isNotEmpty) {
        final latestPrevious = previousRecords.last;
        final prevHeight =
            (latestPrevious["height"] as num).toDouble();
        final prevMonth =
            (latestPrevious["month"] as num).toInt();

        if (height < prevHeight) {
          if (mounted) Navigator.pop(context); // dismiss loading
          _showHeightWarningDialog(
            prevHeight: prevHeight,
            prevMonth: prevMonth,
            enteredHeight: height,
            month: month,
            weight: weight,
          );
          return;
        }
      }

      // All good — save and navigate
      await _saveAndNavigate(month, weight, height, existing);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showSnack("Failed to save: $e");
      }
    }
  }

  Future<void> _saveAndNavigate(
    int month,
    double weight,
    double height,
    List<Map<String, dynamic>> existingRecords,
  ) async {
    try {
      await FirestoreService.saveGrowthRecord(
          widget.childId, month, weight, height);

      // Refresh records after save
      final snapshot =
          await FirestoreService.getGrowthRecords(widget.childId);
      final records = snapshot.docs.map((d) => d.data()).toList()
        ..sort((a, b) =>
            (a["month"] as num).compareTo(b["month"] as num));

      if (!mounted) return;
      Navigator.pop(context); // dismiss loading dialog

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

  void _showHeightWarningDialog({
    required double prevHeight,
    required int prevMonth,
    required double enteredHeight,
    required int month,
    required double weight,
  }) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.orange, size: 24),
            SizedBox(width: 8),
            Text("Height Check"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "The height entered is less than a previous record.",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _warningRow("Previous record",
                "${prevHeight.toStringAsFixed(1)} cm at month $prevMonth"),
            _warningRow("Entered height",
                "${enteredHeight.toStringAsFixed(1)} cm at month $month"),
            const SizedBox(height: 12),
            const Text(
              "Height cannot decrease over time. Please check your measurement "
              "and re-enter the correct value.",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text("Fix Height"),
          ),
          ElevatedButton(
            // Allow saving anyway (measurement errors / different device)
            onPressed: () async {
              Navigator.pop(dialogCtx);
              _showLoadingDialog();
              final snapshot = await FirestoreService
                  .getGrowthRecords(widget.childId);
              final existing =
                  snapshot.docs.map((d) => d.data()).toList()
                    ..sort((a, b) => (a["month"] as num)
                        .compareTo(b["month"] as num));
              await _saveAndNavigate(month, weight, enteredHeight, existing);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Save Anyway"),
          ),
        ],
      ),
    );
  }

  Widget _warningRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Text("$label: ",
                style: const TextStyle(
                    color: Colors.grey, fontSize: 13)),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      );

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
          BoxShadow(
              blurRadius: 8,
              color: Colors.black.withOpacity(0.05))
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

            // ── Age toggle ────────────────────────────────────────────
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
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_useYears
                              ? _brandBlue
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
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _useYears
                              ? _brandBlue
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

            // Height note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _brandBlue.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: Color(0xFF2A7FC1)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Height must be equal to or greater than previous records. "
                      "A child's height cannot decrease over time.",
                      style: TextStyle(
                          fontSize: 12, color: Color(0xFF2A7FC1)),
                    ),
                  ),
                ],
              ),
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