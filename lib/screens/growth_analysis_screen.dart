// lib/screens/growth_analysis_screen.dart
// WHO (0–10 years) + CDC (10–18 years) percentile data
// All ages stored and displayed in MONTHS (max 216 = 18 years)

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/firestore_service.dart';

// ── Reference Data ─────────────────────────────────────────────────────────
// Format: month → [P3, P15, P50, P85, P97]
// Sources: WHO Child Growth Standards (0–60m), WHO 5–19 years,
//          CDC Growth Charts (extended to 216m / 18 years)

class _RefData {

  // ── Weight-for-Age BOYS (kg) ──────────────────────────────────────────
  static const Map<int, List<double>> weightBoys = {
    0:   [2.5,  2.9,  3.3,  3.9,  4.4],
    1:   [3.4,  3.9,  4.5,  5.1,  5.7],
    2:   [4.3,  4.9,  5.6,  6.3,  7.1],
    3:   [5.0,  5.7,  6.4,  7.2,  8.0],
    6:   [6.4,  7.1,  7.9,  8.8,  9.8],
    9:   [7.1,  7.9,  8.9,  9.9,  11.0],
    12:  [7.8,  8.6,  9.6,  10.8, 12.0],
    18:  [8.8,  9.7,  10.9, 12.2, 13.6],
    24:  [9.7,  10.8, 12.2, 13.6, 15.3],
    36:  [11.2, 12.4, 14.0, 15.8, 17.8],
    48:  [12.7, 14.1, 16.0, 18.1, 20.5],
    60:  [14.1, 15.7, 18.0, 20.5, 23.2],
    72:  [15.5, 17.4, 20.1, 23.2, 26.8],
    84:  [17.0, 19.2, 22.4, 26.2, 30.8],
    96:  [18.6, 21.2, 25.0, 29.7, 35.6],
    108: [20.3, 23.3, 28.0, 33.8, 41.2],
    120: [22.1, 25.7, 31.4, 38.7, 47.9],
    132: [24.4, 28.6, 35.5, 44.6, 56.0],
    144: [27.3, 32.4, 40.7, 52.0, 65.9],
    156: [31.2, 37.5, 47.3, 60.5, 76.8],
    168: [36.0, 43.6, 54.7, 69.3, 87.2],
    180: [41.2, 49.8, 61.9, 77.5, 96.0],
    192: [45.9, 55.4, 67.8, 84.0, 102.5],
    204: [49.3, 59.3, 72.0, 88.7, 107.0],
    216: [51.5, 62.0, 74.8, 91.8, 110.0],
  };

  // ── Weight-for-Age GIRLS (kg) ─────────────────────────────────────────
  static const Map<int, List<double>> weightGirls = {
    0:   [2.4,  2.8,  3.2,  3.7,  4.2],
    1:   [3.2,  3.6,  4.2,  4.8,  5.5],
    2:   [3.9,  4.5,  5.1,  5.8,  6.6],
    3:   [4.5,  5.2,  5.8,  6.6,  7.5],
    6:   [5.7,  6.5,  7.3,  8.2,  9.3],
    9:   [6.4,  7.3,  8.2,  9.3,  10.6],
    12:  [7.0,  8.0,  9.0,  10.2, 11.5],
    18:  [8.1,  9.1,  10.2, 11.6, 13.2],
    24:  [9.0,  10.2, 11.5, 13.2, 15.1],
    36:  [10.5, 11.8, 13.5, 15.5, 17.8],
    48:  [11.9, 13.5, 15.5, 17.9, 20.7],
    60:  [13.3, 15.2, 17.5, 20.4, 23.7],
    72:  [14.7, 16.9, 19.7, 23.3, 27.8],
    84:  [16.2, 18.8, 22.2, 26.7, 32.8],
    96:  [17.8, 20.9, 25.0, 30.7, 38.7],
    108: [19.6, 23.3, 28.2, 35.3, 45.7],
    120: [21.8, 26.1, 32.0, 40.7, 53.8],
    132: [24.6, 29.7, 36.8, 47.4, 62.8],
    144: [28.3, 34.3, 42.5, 55.1, 72.5],
    156: [33.0, 39.7, 48.7, 63.0, 82.0],
    168: [38.0, 45.3, 55.0, 70.5, 90.5],
    180: [42.0, 49.8, 59.4, 75.5, 96.0],
    192: [44.5, 52.5, 62.0, 78.5, 99.0],
    204: [46.0, 54.0, 63.5, 80.0, 101.0],
    216: [46.8, 55.0, 64.6, 81.0, 102.0],
  };

  // ── Height-for-Age BOYS (cm) ──────────────────────────────────────────
  static const Map<int, List<double>> heightBoys = {
    0:   [46.1, 48.0, 49.9, 51.8, 53.7],
    1:   [50.8, 52.8, 54.7, 56.7, 58.6],
    2:   [54.4, 56.4, 58.4, 60.4, 62.4],
    3:   [57.3, 59.4, 61.4, 63.5, 65.5],
    6:   [63.3, 65.5, 67.6, 69.8, 71.9],
    9:   [68.0, 70.1, 72.3, 74.5, 76.7],
    12:  [71.7, 73.9, 75.7, 77.7, 79.8],
    18:  [78.3, 80.5, 82.3, 84.4, 86.7],
    24:  [83.5, 85.8, 87.8, 90.0, 92.3],
    36:  [91.8, 94.2, 96.1, 98.5, 101.0],
    48:  [98.5, 101.0,103.3,105.7,108.2],
    60:  [104.0,107.0,110.0,113.0,116.0],
    72:  [109.5,112.5,116.0,119.5,123.0],
    84:  [114.5,118.0,121.7,125.5,129.5],
    96:  [119.5,123.2,127.3,131.5,136.0],
    108: [124.0,128.0,132.6,137.2,142.2],
    120: [128.5,132.7,137.5,143.0,148.5],
    132: [133.0,137.5,142.8,149.0,155.0],
    144: [137.5,142.8,148.5,155.5,162.5],
    156: [143.0,149.0,155.5,163.0,170.5],
    168: [150.5,157.0,163.8,170.8,177.8],
    180: [158.0,163.8,169.8,176.2,182.5],
    192: [162.0,167.0,173.0,179.0,185.0],
    204: [163.5,168.5,174.5,180.5,186.5],
    216: [164.0,169.0,175.3,181.5,187.5],
  };

  // ── Height-for-Age GIRLS (cm) ─────────────────────────────────────────
  static const Map<int, List<double>> heightGirls = {
    0:   [45.6, 47.3, 49.1, 51.0, 52.9],
    1:   [50.0, 51.8, 53.7, 55.6, 57.4],
    2:   [53.2, 55.2, 57.1, 59.1, 61.1],
    3:   [55.8, 57.9, 59.8, 61.9, 63.9],
    6:   [61.5, 63.7, 65.7, 67.9, 70.0],
    9:   [66.3, 68.4, 70.5, 72.6, 74.7],
    12:  [70.0, 72.0, 74.0, 76.1, 78.1],
    18:  [76.7, 78.8, 80.7, 83.0, 85.2],
    24:  [82.1, 84.2, 86.4, 88.7, 91.0],
    36:  [90.7, 93.0, 95.1, 97.6, 100.0],
    48:  [97.9, 100.3,102.7,105.3,107.9],
    60:  [104.2,107.0,109.4,112.2,115.0],
    72:  [109.5,112.3,115.1,118.0,121.0],
    84:  [114.5,117.5,120.6,123.8,127.2],
    96:  [119.5,122.8,126.2,129.8,133.7],
    108: [124.5,128.0,131.8,135.7,140.0],
    120: [129.5,133.5,137.8,142.2,147.0],
    132: [135.0,139.5,144.3,149.2,154.5],
    144: [141.5,146.2,151.2,156.5,162.0],
    156: [147.5,152.0,156.8,162.0,167.5],
    168: [151.0,155.3,159.8,164.8,170.0],
    180: [152.5,156.5,161.0,166.0,171.5],
    192: [153.0,157.0,161.5,166.5,172.0],
    204: [153.2,157.2,161.8,166.8,172.2],
    216: [153.3,157.3,162.0,167.0,172.5],
  };

  // ── Band index helper (0=<P3 … 5=>P97) ───────────────────────────────
  static int bandIndex(
      int month, double value, Map<int, List<double>> table) {
    final cm = table.keys.reduce(
        (a, b) => (a - month).abs() < (b - month).abs() ? a : b);
    final bands = table[cm]!;
    if (value < bands[0]) return 0;
    if (value < bands[1]) return 1;
    if (value < bands[2]) return 2;
    if (value < bands[3]) return 3;
    if (value < bands[4]) return 4;
    return 5;
  }

  static String bandString(int band) {
    const labels = [
      "< P3", "P3–P15", "P15–P50", "P50–P85", "P85–P97", "> P97"
    ];
    return labels[band.clamp(0, 5)];
  }

  // ── WHO Clinical Terms ────────────────────────────────────────────────
  static String weightTerm(int month, double value, bool isBoy) {
    switch (bandIndex(
        month, value, isBoy ? weightBoys : weightGirls)) {
      case 0: return "Severely Underweight";
      case 1: return "Underweight";
      case 2: return "Normal Weight";
      case 3: return "Normal Weight";
      case 4: return "Risk of Overweight";
      default: return "Overweight";
    }
  }

  static String heightTerm(int month, double value, bool isBoy) {
    switch (bandIndex(
        month, value, isBoy ? heightBoys : heightGirls)) {
      case 0: return "Severely Stunted";
      case 1: return "Stunted";
      case 2: return "Normal Height";
      case 3: return "Normal Height";
      case 4: return "Tall";
      default: return "Very Tall";
    }
  }

  static String weightBand(int month, double value, bool isBoy) =>
      bandString(bandIndex(
          month, value, isBoy ? weightBoys : weightGirls));

  static String heightBand(int month, double value, bool isBoy) =>
      bandString(bandIndex(
          month, value, isBoy ? heightBoys : heightGirls));

  static Color termColor(String term) {
    switch (term) {
      case "Severely Underweight":
      case "Severely Stunted":
        return const Color(0xFFC62828);
      case "Underweight":
      case "Stunted":
        return const Color(0xFFE65100);
      case "Normal Weight":
      case "Normal Height":
        return const Color(0xFF2E7D32);
      case "Risk of Overweight":
      case "Tall":
        return const Color(0xFFE65100);
      case "Overweight":
      case "Very Tall":
        return const Color(0xFF1565C0);
      default:
        return Colors.grey;
    }
  }

  static String termAdvice(String term) {
    switch (term) {
      case "Severely Underweight":
        return "Urgent: seek medical attention immediately";
      case "Underweight":
        return "Monitor diet — consult a healthcare provider";
      case "Normal Weight":
        return "Healthy weight for age ✓";
      case "Risk of Overweight":
        return "Monitor diet and physical activity";
      case "Overweight":
        return "Consult a healthcare provider for guidance";
      case "Severely Stunted":
        return "Urgent: possible chronic malnutrition — see a doctor";
      case "Stunted":
        return "Possible growth faltering — consult a doctor";
      case "Normal Height":
        return "Normal growth for age ✓";
      case "Tall":
        return "Above average height — generally healthy";
      case "Very Tall":
        return "Exceptionally tall — routine check-up advised";
      default:
        return "";
    }
  }

  static List<FlSpot> spotsForBand(
      Map<int, List<double>> table, int idx) {
    return table.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value[idx]))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));
  }

  /// Returns the WHO P50 (median) reference values for a given age.
  /// Returns [weight_kg, height_cm] at the median (P50).
  static List<double> p50Reference(int month, bool isBoy) {
    final wTable = isBoy ? weightBoys : weightGirls;
    final hTable = isBoy ? heightBoys : heightGirls;

    final wCm = wTable.keys.reduce(
        (a, b) => (a - month).abs() < (b - month).abs() ? a : b);
    final hCm = hTable.keys.reduce(
        (a, b) => (a - month).abs() < (b - month).abs() ? a : b);

    return [wTable[wCm]![2], hTable[hCm]![2]]; // index 2 = P50
  }
}

// ── Age label helper ──────────────────────────────────────────────────────
String _ageLabel(int months) {
  if (months == 0) return "Birth";
  if (months < 12) return "${months}m";
  final years = months ~/ 12;
  final rem   = months % 12;
  if (rem == 0) return "${years}y";
  return "${years}y ${rem}m";
}

// ─────────────────────────────────────────────────────────────────────────────

class GrowthAnalysisScreen extends StatefulWidget {
  final String childId;
  final String childName;
  final String gender;
  final List<Map<String, dynamic>>? initialRecords;

  const GrowthAnalysisScreen({
    super.key,
    required this.childId,
    required this.childName,
    required this.gender,
    this.initialRecords,
  });

  @override
  State<GrowthAnalysisScreen> createState() =>
      _GrowthAnalysisScreenState();
}

class _GrowthAnalysisScreenState extends State<GrowthAnalysisScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> records = [];
  bool isLoading = true;
  late TabController _tabController;

  bool get _isBoy => widget.gender != "Girl";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.initialRecords != null) {
      records    = widget.initialRecords!;
      isLoading  = false;
    } else {
      fetchRecords();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchRecords() async {
    try {
      final snapshot =
          await FirestoreService.getGrowthRecords(widget.childId);
      final data = snapshot.docs.map((doc) => doc.data()).toList();
      data.sort(
          (a, b) => (a["month"] as num).compareTo(b["month"] as num));
      setState(() {
        records   = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error loading records: $e")));
      }
    }
  }

  // ── Chart helpers ─────────────────────────────────────────────────────

  LineChartBarData _bandLine(
      Map<int, List<double>> table, int idx, Color color) {
    return LineChartBarData(
      isCurved: true,
      color: color.withOpacity(0.55),
      barWidth: 1.2,
      dashArray: [4, 4],
      spots: _RefData.spotsForBand(table, idx),
      dotData: const FlDotData(show: false),
    );
  }

  LineChartBarData _childLine(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      isCurved: true,
      color: color,
      barWidth: 3.5,
      spots: spots,
      dotData: FlDotData(
        show: true,
        getDotPainter: (s, _, __, ___) => FlDotCirclePainter(
          radius: 5,
          color: color,
          strokeWidth: 2,
          strokeColor: Colors.white,
        ),
      ),
      belowBarData: BarAreaData(
          show: true, color: color.withOpacity(0.08)),
    );
  }

  List<FlSpot> _weightSpots() => records
      .map((e) => FlSpot((e["month"] as num).toDouble(),
          (e["weight"] as num).toDouble()))
      .toList();

  List<FlSpot> _heightSpots() => records
      .map((e) => FlSpot((e["month"] as num).toDouble(),
          (e["height"] as num).toDouble()))
      .toList();

  Widget _buildChart({required bool isWeight, required Color childColor}) {
    final table = isWeight
        ? (_isBoy ? _RefData.weightBoys : _RefData.weightGirls)
        : (_isBoy ? _RefData.heightBoys : _RefData.heightGirls);

    final childSpots = isWeight ? _weightSpots() : _heightSpots();

    // Y-axis range depends on type
    final minY = isWeight ? 0.0  : 40.0;
    final maxY = isWeight ? 120.0 : 225.0;

    final lines = <LineChartBarData>[
      _bandLine(table, 0, Colors.red),
      _bandLine(table, 1, Colors.orange),
      _bandLine(table, 2, Colors.green),
      _bandLine(table, 3, Colors.orange),
      _bandLine(table, 4, Colors.red),
      if (childSpots.isNotEmpty) _childLine(childSpots, childColor),
    ];

    return LineChart(LineChartData(
      minX: 0,
      maxX: 216, // 18 years
      minY: minY,
      maxY: maxY,
      clipData: const FlClipData.all(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        verticalInterval: 24, // every 2 years
        horizontalInterval: isWeight ? 20 : 25,
        getDrawingHorizontalLine: (v) =>
            FlLine(color: Colors.grey.shade200, strokeWidth: 1),
        getDrawingVerticalLine: (v) =>
            FlLine(color: Colors.grey.shade100, strokeWidth: 1),
      ),
      borderData: FlBorderData(
          border: Border.all(color: Colors.grey.shade300)),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          axisNameWidget: const Text("Age",
              style: TextStyle(fontSize: 11, color: Colors.grey)),
          sideTitles: SideTitles(
            showTitles: true,
            interval: 24, // label every 2 years
            reservedSize: 28,
            getTitlesWidget: (v, _) {
              final years = v ~/ 12;
              return Text("${years}y",
                  style: const TextStyle(fontSize: 9));
            },
          ),
        ),
        leftTitles: AxisTitles(
          axisNameWidget: Text(
              isWeight ? "Weight (kg)" : "Height (cm)",
              style:
                  const TextStyle(fontSize: 11, color: Colors.grey)),
          sideTitles: SideTitles(
            showTitles: true,
            interval: isWeight ? 20 : 25,
            reservedSize: 36,
            getTitlesWidget: (v, _) => Text("${v.toInt()}",
                style: const TextStyle(fontSize: 10)),
          ),
        ),
        topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
      ),
      lineBarsData: lines,
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (spots) => spots.map((s) {
            if (s.barIndex == lines.length - 1) {
              return LineTooltipItem(
                "${_ageLabel(s.x.toInt())}\n"
                "${isWeight ? '${s.y.toStringAsFixed(1)} kg' : '${s.y.toStringAsFixed(1)} cm'}",
                TextStyle(
                    color: childColor, fontWeight: FontWeight.bold),
              );
            }
            return null;
          }).toList(),
        ),
      ),
    ));
  }

  // ── Legend ────────────────────────────────────────────────────────────

  Widget _legend(Color childColor, String childLabel) {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: [
        _legendItem(childColor, childLabel, false),
        _legendItem(Colors.red.withOpacity(0.55), "P3 / P97", true),
        _legendItem(Colors.orange.withOpacity(0.6), "P15 / P85", true),
        _legendItem(Colors.green, "P50 (median)", true),
      ],
    );
  }

  Widget _legendItem(Color c, String label, bool dashed) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 3,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      );

  // ── Summary card ──────────────────────────────────────────────────────

  Widget _summaryCard() {
    if (records.isEmpty) return const SizedBox.shrink();
    final latest  = records.last;
    final month   = (latest["month"] as num).toInt();
    final weight  = (latest["weight"] as num).toDouble();
    final height  = (latest["height"] as num).toDouble();

    final wTerm   = _RefData.weightTerm(month, weight, _isBoy);
    final hTerm   = _RefData.heightTerm(month, height, _isBoy);
    final wBand   = _RefData.weightBand(month, weight, _isBoy);
    final hBand   = _RefData.heightBand(month, height, _isBoy);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              blurRadius: 8, color: Colors.black.withOpacity(0.06))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Latest — ${_ageLabel(month)}",
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 14),
          _percentileRow(
            icon: Icons.monitor_weight_outlined,
            label: "Weight",
            value: "${weight.toStringAsFixed(1)} kg",
            whoTerm: wTerm,
            band: wBand,
          ),
          const Divider(height: 20),
          _percentileRow(
            icon: Icons.height,
            label: "Height",
            value: "${height.toStringAsFixed(1)} cm",
            whoTerm: hTerm,
            band: hBand,
          ),
          const SizedBox(height: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "Percentiles compare your child to 100 children of the "
              "same age and gender. P3–P97 is the normal range. "
              "Data: WHO (0–10 years) + CDC (10–18 years).",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _percentileRow({
    required IconData icon,
    required String label,
    required String value,
    required String whoTerm,
    required String band,
  }) {
    final color  = _RefData.termColor(whoTerm);
    final advice = _RefData.termAdvice(whoTerm);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text("$label: ",
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 13)),
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(whoTerm,
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 11)),
                ),
              ]),
              const SizedBox(height: 3),
              Text("Percentile: $band",
                  style: TextStyle(
                      color: Colors.grey.shade500, fontSize: 11)),
              const SizedBox(height: 2),
              Text(advice,
                  style: TextStyle(color: color, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FD),
      appBar: AppBar(
        title: Text("${widget.childName}'s Growth"),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2A7FC1),
          tabs: const [
            Tab(icon: Icon(Icons.monitor_weight_outlined), text: "Weight"),
            Tab(icon: Icon(Icons.height), text: "Height"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : records.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.insert_chart_outlined,
                            size: 90,
                            color: const Color(0xFF2A7FC1)
                                .withOpacity(0.3)),
                        const SizedBox(height: 20),
                        const Text("No growth data yet",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        const Text(
                          "Once measurements are added, the growth chart "
                          "will appear here with WHO/CDC percentile bands "
                          "covering birth to 18 years.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.add),
                          label: const Text("Add First Measurement"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchRecords,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _summaryCard(),
                        const SizedBox(height: 20),

                        // Chart card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 8,
                                  color: Colors.black.withOpacity(0.05))
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 320,
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    Column(children: [
                                      _legend(Colors.pinkAccent,
                                          "Child weight"),
                                      const SizedBox(height: 10),
                                      Expanded(
                                          child: _buildChart(
                                              isWeight: true,
                                              childColor:
                                                  Colors.pinkAccent)),
                                    ]),
                                    Column(children: [
                                      _legend(Colors.deepPurple,
                                          "Child height"),
                                      const SizedBox(height: 10),
                                      Expanded(
                                          child: _buildChart(
                                              isWeight: false,
                                              childColor:
                                                  Colors.deepPurple)),
                                    ]),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // History
                        const SizedBox(height: 24),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text("All Records",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 12),
                        ...records.reversed.map((r) {
                          final month  = (r["month"] as num).toInt();
                          final weight = (r["weight"] as num).toDouble();
                          final height = (r["height"] as num).toDouble();
                          final wTerm  =
                              _RefData.weightTerm(month, weight, _isBoy);
                          final hTerm  =
                              _RefData.heightTerm(month, height, _isBoy);
                          final wBand  =
                              _RefData.weightBand(month, weight, _isBoy);
                          final hBand  =
                              _RefData.heightBand(month, height, _isBoy);
                          // WHO P50 reference for this age
                          final ref    = _RefData.p50Reference(month, _isBoy);
                          final refW   = ref[0];
                          final refH   = ref[1];

                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ── Record header with edit/delete ──
                                  Row(
                                    children: [
                                      Text(_ageLabel(month),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15)),
                                      const Spacer(),
                                      // Edit record
                                      IconButton(
                                        icon: const Icon(
                                            Icons.edit_outlined,
                                            size: 18,
                                            color: Color(0xFF2A7FC1)),
                                        tooltip: "Edit record",
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () => _showEditRecordDialog(
                                            month, weight, height),
                                      ),
                                      const SizedBox(width: 8),
                                      // Delete record
                                      IconButton(
                                        icon: const Icon(
                                            Icons.delete_outline,
                                            size: 18,
                                            color: Colors.redAccent),
                                        tooltip: "Delete record",
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () =>
                                            _confirmDeleteRecord(month),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: _miniTile(
                                              "Weight",
                                              "${weight.toStringAsFixed(1)} kg",
                                              wTerm,
                                              wBand)),
                                      const SizedBox(width: 10),
                                      Expanded(
                                          child: _miniTile(
                                              "Height",
                                              "${height.toStringAsFixed(1)} cm",
                                              hTerm,
                                              hBand)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // WHO reference row
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2A7FC1)
                                          .withOpacity(0.07),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                            Icons.info_outline,
                                            size: 14,
                                            color: Color(0xFF2A7FC1)),
                                        const SizedBox(width: 6),
                                        Text(
                                          "WHO median for ${_ageLabel(month)}:  "
                                          "${refW.toStringAsFixed(1)} kg  •  "
                                          "${refH.toStringAsFixed(1)} cm",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF2A7FC1)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
    );
  }

  // ── Edit growth record dialog ─────────────────────────────────────────

  void _showEditRecordDialog(
      int month, double currentWeight, double currentHeight) {
    final weightCtrl =
        TextEditingController(text: currentWeight.toStringAsFixed(1));
    final heightCtrl =
        TextEditingController(text: currentHeight.toStringAsFixed(1));
    // Capture scaffold context before entering dialog
    final scaffoldCtx = context;

    showDialog(
      context: scaffoldCtx,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text("Edit — ${_ageLabel(month)}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _editField("Weight (kg)", weightCtrl, "e.g. 12.5"),
            const SizedBox(height: 14),
            _editField("Height (cm)", heightCtrl, "e.g. 85.0"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final w = double.tryParse(weightCtrl.text.trim());
              final h = double.tryParse(heightCtrl.text.trim());
              if (w == null || h == null || w <= 0 || h <= 0) {
                ScaffoldMessenger.of(dialogCtx).showSnackBar(
                  const SnackBar(
                      content: Text("Please enter valid values.")));
                return;
              }
              Navigator.pop(dialogCtx);
              try {
                await FirestoreService.updateGrowthRecord(
                    widget.childId, month, w, h);
                if (mounted) await fetchRecords();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(scaffoldCtx).showSnackBar(
                      SnackBar(content: Text("Error: $e")));
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
    );
  }

  Widget _editField(
      String label, TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ── Delete growth record confirmation ──────────────────────────────────

  void _confirmDeleteRecord(int month) {
    final scaffoldCtx = context;
    showDialog(
      context: scaffoldCtx,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Record"),
        content: Text(
            "Delete the growth record for ${_ageLabel(month)}? "
            "This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              try {
                await FirestoreService.deleteGrowthRecord(
                    widget.childId, month);
                if (mounted) await fetchRecords();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(scaffoldCtx).showSnackBar(
                      SnackBar(content: Text("Error: $e")));
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

  Widget _miniTile(
      String label, String value, String whoTerm, String band) {
    final color = _RefData.termColor(whoTerm);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.grey, fontSize: 12)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(whoTerm,
                style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 2),
          Text(band,
              style: TextStyle(
                  color: Colors.grey.shade500, fontSize: 10)),
        ],
      ),
    );
  }
}