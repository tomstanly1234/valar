// lib/screens/vaccination_screen.dart

import 'package:flutter/material.dart';
import '../models/vaccine_model.dart';
import '../services/vaccination_service.dart';
import '../services/firestore_service.dart';

class VaccinationScreen extends StatefulWidget {
  final String    childId;
  final String    childName;
  final String    gender;
  final DateTime? dob; // optional — used to auto-calculate age for vaccines

  const VaccinationScreen({
    super.key,
    required this.childId,
    required this.childName,
    required this.gender,
    this.dob,
  });

  @override
  State<VaccinationScreen> createState() => _VaccinationScreenState();
}

class _VaccinationScreenState extends State<VaccinationScreen> {
  Map<String, bool> _doneMap = {};
  bool _isLoading = true;

  static const Color _brandBlue = Color(0xFF2A7FC1);
  static const Color _green     = Color(0xFF2E7D32);
  static const Color _orange    = Color(0xFFE65100);
  static const Color _red       = Color(0xFFC62828);
  static const Color _grey      = Color(0xFF757575);

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final status =
        await VaccinationService.getVaccinationStatus(widget.childId);
    setState(() {
      _doneMap   = status;
      _isLoading = false;
    });
  }

  Future<void> _toggle(String vaccineId, bool current) async {
    final next = !current;
    setState(() => _doneMap[vaccineId] = next);
    await VaccinationService.setVaccineDone(
        widget.childId, vaccineId, next);
  }

  // ── Age — calculated live from DOB ────────────────────────────────────
  int get _ageMonths => widget.dob != null
      ? FirestoreService.ageInMonthsFromDob(widget.dob!)
      : 0;

  String _ageString(int months) {
    if (months < 1)  return "< 1 month";
    if (months < 12) return "$months months";
    final y = months ~/ 12;
    final m = months % 12;
    if (m == 0) return "$y year${y > 1 ? 's' : ''}";
    return "${y}y ${m}m";
  }

  // ── Status helpers ────────────────────────────────────────────────────

  VaccineStatus _status(VaccineModel v) => getVaccineStatus(
        childAgeMonths: _ageMonths,
        dueAtMonth:     v.dueAtMonth,
        isDone:         _doneMap[v.id] ?? false,
      );

  Color _statusColor(VaccineStatus s) {
    switch (s) {
      case VaccineStatus.done:     return _green;
      case VaccineStatus.overdue:  return _red;
      case VaccineStatus.dueNow:   return _orange;
      case VaccineStatus.upcoming: return _grey;
    }
  }

  String _statusLabel(VaccineStatus s) {
    switch (s) {
      case VaccineStatus.done:     return "✓  Done";
      case VaccineStatus.overdue:  return "⚠  Overdue";
      case VaccineStatus.dueNow:   return "!  Due Now";
      case VaccineStatus.upcoming: return "  Upcoming";
    }
  }

  IconData _statusIcon(VaccineStatus s) {
    switch (s) {
      case VaccineStatus.done:     return Icons.check_circle;
      case VaccineStatus.overdue:  return Icons.warning_rounded;
      case VaccineStatus.dueNow:   return Icons.notifications_active;
      case VaccineStatus.upcoming: return Icons.schedule;
    }
  }

  // ── Counts ────────────────────────────────────────────────────────────

  List<VaccineModel> get _schedule => iapVaccineSchedule
      .where((v) => !(v.girlsOnly && widget.gender != "Girl"))
      .toList();

  int get _doneCount =>
      _schedule.where((v) => _doneMap[v.id] == true).length;

  int get _overdueCount =>
      _schedule.where((v) => _status(v) == VaccineStatus.overdue).length;

  int get _dueNowCount =>
      _schedule.where((v) => _status(v) == VaccineStatus.dueNow).length;

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final grouped = vaccinesByAge(widget.gender);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${widget.childName}'s Vaccines",
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (widget.dob != null)
              Text(
                "Age: ${_ageString(_ageMonths)}  •  "
                "DOB: ${widget.dob!.day}/${widget.dob!.month}/${widget.dob!.year}",
                style: const TextStyle(
                    fontSize: 11, color: Colors.grey),
              )
            else
              const Text(
                "No DOB set — add DOB for auto tracking",
                style: TextStyle(fontSize: 11, color: Colors.orange),
              ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                "$_doneCount/${_schedule.length} done",
                style: const TextStyle(
                    color: _green, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatus,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [

                  // ── No DOB warning ──────────────────────────────
                  if (widget.dob == null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _orange.withOpacity(0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Color(0xFFE65100), size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "No date of birth recorded. All vaccines shown as "
                              "Upcoming. Add DOB when creating the child profile "
                              "to enable automatic overdue detection.",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFE65100)),
                            ),
                          ),
                        ],
                      ),
                    ),

                  _summaryBanner(),
                  const SizedBox(height: 16),

                  if (_overdueCount > 0) ...[
                    _overdueAlertBox(),
                    const SizedBox(height: 16),
                  ],

                  ...grouped.entries
                      .map((e) => _ageGroup(e.key, e.value)),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Schedule based on IAP (Indian Academy of Pediatrics) "
                      "immunisation guidelines — Birth to 18 Years. "
                      "Always consult your paediatrician for personalised advice.",
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  // ── Summary banner ────────────────────────────────────────────────────

  Widget _summaryBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: _brandBlue,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryTile("Done",    "$_doneCount",         Colors.greenAccent),
          _vDiv(),
          _summaryTile("Overdue", "$_overdueCount",      Colors.redAccent),
          _vDiv(),
          _summaryTile("Due Now", "$_dueNowCount",       Colors.orangeAccent),
          _vDiv(),
          _summaryTile("Total",   "${_schedule.length}", Colors.white),
        ],
      ),
    );
  }

  Widget _summaryTile(String label, String count, Color color) => Column(
        children: [
          Text(count,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color)),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.85))),
        ],
      );

  Widget _vDiv() => Container(
      height: 36, width: 1, color: Colors.white.withOpacity(0.3));

  // ── Overdue alert box ─────────────────────────────────────────────────

  Widget _overdueAlertBox() {
    final overdue = _schedule
        .where((v) => _status(v) == VaccineStatus.overdue)
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _red.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.warning_rounded, color: _red, size: 20),
            const SizedBox(width: 8),
            Text(
              "$_overdueCount Vaccine${_overdueCount > 1 ? 's' : ''} Overdue",
              style: const TextStyle(
                  color: _red,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
          ]),
          const SizedBox(height: 8),
          ...overdue.map((v) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  "• ${v.name} — due at ${ageLabel(v.dueAtMonth)}",
                  style: TextStyle(
                      color: _red.withOpacity(0.85), fontSize: 13),
                ),
              )),
          const SizedBox(height: 8),
          const Text(
            "Please consult your paediatrician for catch-up vaccination.",
            style: TextStyle(
                color: _red, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ── Age group ─────────────────────────────────────────────────────────

  Widget _ageGroup(int monthAge, List<VaccineModel> vaccines) {
    final hasOverdue =
        vaccines.any((v) => _status(v) == VaccineStatus.overdue);
    final hasDueNow =
        vaccines.any((v) => _status(v) == VaccineStatus.dueNow);
    final allDone =
        vaccines.every((v) => _status(v) == VaccineStatus.done);

    Color hc = _brandBlue;
    if (allDone)    hc = _green;
    if (hasDueNow)  hc = _orange;
    if (hasOverdue) hc = _red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: hc.withOpacity(0.11),
            borderRadius: BorderRadius.circular(10),
            border: Border(left: BorderSide(color: hc, width: 4)),
          ),
          child: Row(
            children: [
              Text(ageLabel(monthAge),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: hc)),
              const Spacer(),
              if (allDone)
                const Icon(Icons.check_circle, color: _green, size: 18),
            ],
          ),
        ),
        ...vaccines.map(_vaccineCard),
        const SizedBox(height: 10),
      ],
    );
  }

  // ── Vaccine card ──────────────────────────────────────────────────────

  Widget _vaccineCard(VaccineModel v) {
    final status = _status(v);
    final color  = _statusColor(status);
    final isDone = _doneMap[v.id] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1.5,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context)
            .copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.12),
            child: Icon(_statusIcon(status), color: color, size: 20),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(v.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
              ),
              if (v.girlsOnly)
                Container(
                  margin: const EdgeInsets.only(left: 6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text("Girls",
                      style: TextStyle(
                          fontSize: 10, color: Colors.pinkAccent)),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(v.dose,
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_statusLabel(status),
                    style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isDone ? "Done" : "Mark\nDone",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11,
                      color: isDone ? _green : Colors.grey)),
              Checkbox(
                value: isDone,
                activeColor: _green,
                onChanged: (_) => _toggle(v.id, isDone),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 6),
                  Text(v.fullName,
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic)),
                  const SizedBox(height: 10),
                  _detailRow(Icons.shield_outlined,
                      "Protects against", v.description, _brandBlue),
                  if (status == VaccineStatus.overdue) ...[
                    const SizedBox(height: 10),
                    _detailRow(Icons.warning_amber_rounded,
                        "Consequence of delay", v.consequence, _red),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _toggle(v.id, isDone),
                      icon: Icon(
                          isDone ? Icons.undo : Icons.check, size: 18),
                      label: Text(
                          isDone ? "Mark as Not Done" : "Mark as Done ✓"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDone ? Colors.grey : _green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
      IconData icon, String label, String content, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 3),
              Text(content,
                  style: const TextStyle(fontSize: 13, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}