import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/firestore_service.dart';

// ── WHO Percentile Data ────────────────────────────────────────────────────
// Source: WHO Child Growth Standards (boys & girls, 0–60 months)
// Columns: month → [3rd, 15th, 50th, 85th, 97th] percentile

class _WhoData {
  // Weight-for-age BOYS (kg)
  static const Map<int, List<double>> weightBoys = {
    0:  [2.5, 2.9, 3.3, 3.9, 4.4],
    1:  [3.4, 3.9, 4.5, 5.1, 5.7],
    2:  [4.3, 4.9, 5.6, 6.3, 7.1],
    3:  [5.0, 5.7, 6.4, 7.2, 8.0],
    4:  [5.6, 6.2, 7.0, 7.8, 8.7],
    5:  [6.0, 6.7, 7.5, 8.4, 9.3],
    6:  [6.4, 7.1, 7.9, 8.8, 9.8],
    9:  [7.1, 7.9, 8.9, 9.9, 11.0],
    12: [7.8, 8.6, 9.6, 10.8, 12.0],
    15: [8.4, 9.2, 10.3, 11.5, 12.8],
    18: [8.8, 9.7, 10.9, 12.2, 13.6],
    24: [9.7, 10.8, 12.2, 13.6, 15.3],
    30: [10.5, 11.5, 13.0, 14.6, 16.4],
    36: [11.2, 12.4, 14.0, 15.8, 17.8],
    42: [11.9, 13.2, 15.0, 16.9, 19.1],
    48: [12.7, 14.1, 16.0, 18.1, 20.5],
    54: [13.4, 14.9, 17.0, 19.3, 21.9],
    60: [14.1, 15.7, 18.0, 20.5, 23.2],
  };

  // Weight-for-age GIRLS (kg)
  static const Map<int, List<double>> weightGirls = {
    0:  [2.4, 2.8, 3.2, 3.7, 4.2],
    1:  [3.2, 3.6, 4.2, 4.8, 5.5],
    2:  [3.9, 4.5, 5.1, 5.8, 6.6],
    3:  [4.5, 5.2, 5.8, 6.6, 7.5],
    4:  [5.0, 5.7, 6.4, 7.3, 8.2],
    5:  [5.4, 6.1, 6.9, 7.8, 8.8],
    6:  [5.7, 6.5, 7.3, 8.2, 9.3],
    9:  [6.4, 7.3, 8.2, 9.3, 10.6],
    12: [7.0, 8.0, 9.0, 10.2, 11.5],
    15: [7.6, 8.6, 9.7, 11.0, 12.4],
    18: [8.1, 9.1, 10.2, 11.6, 13.2],
    24: [9.0, 10.2, 11.5, 13.2, 15.1],
    30: [9.8, 11.0, 12.5, 14.3, 16.4],
    36: [10.5, 11.8, 13.5, 15.5, 17.8],
    42: [11.2, 12.6, 14.5, 16.7, 19.2],
    48: [11.9, 13.5, 15.5, 17.9, 20.7],
    54: [12.6, 14.3, 16.5, 19.2, 22.2],
    60: [13.3, 15.2, 17.5, 20.4, 23.7],
  };

  // Height-for-age BOYS (cm)
  static const Map<int, List<double>> heightBoys = {
    0:  [46.1, 48.0, 49.9, 51.8, 53.7],
    1:  [50.8, 52.8, 54.7, 56.7, 58.6],
    2:  [54.4, 56.4, 58.4, 60.4, 62.4],
    3:  [57.3, 59.4, 61.4, 63.5, 65.5],
    4:  [59.7, 61.8, 63.9, 66.0, 68.0],
    5:  [61.7, 63.8, 65.9, 68.0, 70.1],
    6:  [63.3, 65.5, 67.6, 69.8, 71.9],
    9:  [68.0, 70.1, 72.3, 74.5, 76.7],
    12: [71.7, 73.9, 75.7, 77.7, 79.8],
    15: [75.0, 77.3, 79.1, 81.2, 83.4],
    18: [78.3, 80.5, 82.3, 84.4, 86.7],
    24: [83.5, 85.8, 87.8, 90.0, 92.3],
    30: [88.0, 90.4, 92.7, 95.0, 97.4],
    36: [91.8, 94.2, 96.1, 98.5, 101.0],
    42: [95.3, 97.7, 99.9, 102.3, 104.8],
    48: [98.5, 101.0, 103.3, 105.7, 108.2],
    54: [101.5, 104.0, 106.4, 108.9, 111.5],
    60: [104.0, 107.0, 110.0, 113.0, 116.0],
  };

  // Height-for-age GIRLS (cm)
  static const Map<int, List<double>> heightGirls = {
    0:  [45.6, 47.3, 49.1, 51.0, 52.9],
    1:  [50.0, 51.8, 53.7, 55.6, 57.4],
    2:  [53.2, 55.2, 57.1, 59.1, 61.1],
    3:  [55.8, 57.9, 59.8, 61.9, 63.9],
    4:  [58.0, 60.1, 62.1, 64.1, 66.2],
    5:  [59.9, 62.0, 64.0, 66.1, 68.2],
    6:  [61.5, 63.7, 65.7, 67.9, 70.0],
    9:  [66.3, 68.4, 70.5, 72.6, 74.7],
    12: [70.0, 72.0, 74.0, 76.1, 78.1],
    15: [73.3, 75.5, 77.5, 79.7, 81.8],
    18: [76.7, 78.8, 80.7, 83.0, 85.2],
    24: [82.1, 84.2, 86.4, 88.7, 91.0],
    30: [86.8, 89.1, 91.4, 93.8, 96.2],
    36: [90.7, 93.0, 95.1, 97.6, 100.0],
    42: [94.4, 96.8, 98.7, 101.4, 103.9],
    48: [97.9, 100.3, 102.7, 105.3, 107.9],
    54: [101.2, 103.8, 106.2, 108.9, 111.5],
    60: [104.2, 107.0, 109.4, 112.2, 115.0],
  };

  // ── WHO Clinical Classification ─────────────────────────────────────────
  // Based on WHO Child Growth Standards Z-score cutoffs:
  //   < P3   ≈ < −2 SD  → clinical action required
  //   P3–P15 ≈ −2 to −1 SD → monitor
  //   P15–P85 ≈ −1 to +1 SD → normal
  //   P85–P97 ≈ +1 to +2 SD → monitor
  //   > P97  ≈ > +2 SD  → clinical review

  /// Returns 0–5 band index (0=<P3, 5=>P97)
  static int _bandIndex(int month, double value, Map<int, List<double>> table) {
    final cm = table.keys
        .reduce((a, b) => (a - month).abs() < (b - month).abs() ? a : b);
    final bands = table[cm]!;
    if (value < bands[0]) return 0;
    if (value < bands[1]) return 1;
    if (value < bands[2]) return 2;
    if (value < bands[3]) return 3;
    if (value < bands[4]) return 4;
    return 5;
  }

  /// WHO Weight-for-Age classification (WAZ)
  static String weightForAgeLabel(int month, double value, bool isBoy) {
    switch (_bandIndex(month, value, isBoy ? weightBoys : weightGirls)) {
      case 0: return "Severely Underweight";
      case 1: return "Underweight";
      case 2: return "Normal Weight";
      case 3: return "Normal Weight";
      case 4: return "Risk of Overweight";
      default: return "Overweight";
    }
  }

  /// WHO Height/Length-for-Age classification (HAZ)
  static String heightForAgeLabel(int month, double value, bool isBoy) {
    switch (_bandIndex(month, value, isBoy ? heightBoys : heightGirls)) {
      case 0: return "Severely Stunted";
      case 1: return "Stunted";
      case 2: return "Normal Height";
      case 3: return "Normal Height";
      case 4: return "Tall";
      default: return "Very Tall";
    }
  }

  /// Percentile band string for chart labels
  static String weightPercentileLabel(int month, double value, bool isBoy) =>
      _bandString(_bandIndex(month, value, isBoy ? weightBoys : weightGirls));

  static String heightPercentileLabel(int month, double value, bool isBoy) =>
      _bandString(_bandIndex(month, value, isBoy ? heightBoys : heightGirls));

  static String _bandString(int band) {
    const labels = ["< P3", "P3–P15", "P15–P50", "P50–P85", "P85–P97", "> P97"];
    return labels[band.clamp(0, 5)];
  }

  /// WHO traffic-light color coding
  static Color percentileColor(String whoTerm) {
    switch (whoTerm) {
      case "Severely Underweight":
      case "Severely Stunted":
        return Colors.red.shade800;
      case "Underweight":
      case "Stunted":
        return Colors.orange.shade800;
      case "Normal Weight":
      case "Normal Height":
        return Colors.green.shade700;
      case "Risk of Overweight":
      case "Tall":
        return Colors.orange.shade700;
      case "Overweight":
      case "Very Tall":
        return Colors.blue.shade700;
      default:
        return Colors.grey;
    }
  }

  /// Clinical advice per WHO term
  static String percentileInterpretation(String whoTerm) {
    switch (whoTerm) {
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

  /// Builds sorted FlSpots for a given percentile index (0=P3 … 4=P97).
  static List<FlSpot> spotsForPercentile(
      Map<int, List<double>> table, int index) {
    return table.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value[index]))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));
  }
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
      records = widget.initialRecords!;
      isLoading = false;
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
        records = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading records: $e")),
        );
      }
    }
  }

  // ── Percentile band lines ────────────────────────────────────────────────

  /// Builds a faint percentile reference line.
  LineChartBarData _percentileLine(
    Map<int, List<double>> table,
    int index,
    Color color,
  ) {
    return LineChartBarData(
      isCurved: true,
      color: color.withOpacity(0.55),
      barWidth: 1.2,
      dashArray: [4, 4],
      spots: _WhoData.spotsForPercentile(table, index),
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    );
  }

  /// Shaded area between two percentile lines.
  LineChartBarData _shadedBand(
    Map<int, List<double>> table,
    int lowerIndex,
    int upperIndex,
    Color fillColor,
  ) {
    final upperSpots = _WhoData.spotsForPercentile(table, upperIndex);
    final lowerSpots = _WhoData.spotsForPercentile(table, lowerIndex);
    return LineChartBarData(
      isCurved: true,
      color: Colors.transparent,
      barWidth: 0,
      spots: upperSpots,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: fillColor.withOpacity(0.12),
        cutOffY: lowerSpots.first.y, // approximate lower boundary
        applyCutOffY: false,
      ),
    );
  }

  /// The child's actual data line.
  LineChartBarData _childLine(
      List<FlSpot> spots, Color color) {
    return LineChartBarData(
      isCurved: true,
      color: color,
      barWidth: 3.5,
      spots: spots,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
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

  // ── Full chart ───────────────────────────────────────────────────────────

  Widget _buildChart({
    required String type, // "weight" or "height"
    required Color childColor,
  }) {
    final isWeight = type == "weight";
    final table = isWeight
        ? (_isBoy ? _WhoData.weightBoys : _WhoData.weightGirls)
        : (_isBoy ? _WhoData.heightBoys : _WhoData.heightGirls);

    final childSpots = isWeight ? _weightSpots() : _heightSpots();

    final lines = <LineChartBarData>[
      // Shaded bands (drawn first so child line sits on top)
      _shadedBand(table, 0, 1, Colors.red),      // P3–P15  red tint
      _shadedBand(table, 1, 3, Colors.green),    // P15–P85 green tint
      _shadedBand(table, 3, 4, Colors.orange),   // P85–P97 orange tint

      // Percentile lines
      _percentileLine(table, 0, Colors.red),         // P3
      _percentileLine(table, 1, Colors.orange),      // P15
      _percentileLine(table, 2, Colors.green),       // P50  (median)
      _percentileLine(table, 3, Colors.orange),      // P85
      _percentileLine(table, 4, Colors.red),         // P97

      // Child line (on top)
      if (childSpots.isNotEmpty) _childLine(childSpots, childColor),
    ];

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 60,
        minY: isWeight ? 0 : 40,
        maxY: isWeight ? 26 : 122,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (v) =>
              FlLine(color: Colors.grey.shade200, strokeWidth: 1),
        ),
        borderData:
            FlBorderData(border: Border.all(color: Colors.grey.shade300)),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            axisNameWidget: const Text("Age (months)",
                style: TextStyle(fontSize: 11, color: Colors.grey)),
            sideTitles: SideTitles(
              showTitles: true,
              interval: 12,
              getTitlesWidget: (v, _) => Text("${v.toInt()}",
                  style: const TextStyle(fontSize: 10)),
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: Text(
                isWeight ? "Weight (kg)" : "Height (cm)",
                style:
                    const TextStyle(fontSize: 11, color: Colors.grey)),
            sideTitles: SideTitles(
              showTitles: true,
              interval: isWeight ? 5 : 20,
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
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((s) {
                // Only label the child line (last in list)
                if (s.barIndex == lines.length - 1) {
                  return LineTooltipItem(
                    isWeight
                        ? "${s.y.toStringAsFixed(1)} kg"
                        : "${s.y.toStringAsFixed(1)} cm",
                    TextStyle(
                        color: childColor, fontWeight: FontWeight.bold),
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  // ── Percentile legend ────────────────────────────────────────────────────

  Widget _percentileLegend() {
    return Wrap(
      spacing: 10,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: [
        _legendChip(Colors.red.withOpacity(0.55), "P3"),
        _legendChip(Colors.orange.withOpacity(0.6), "P15"),
        _legendChip(Colors.green, "P50 (median)"),
        _legendChip(Colors.orange.withOpacity(0.6), "P85"),
        _legendChip(Colors.red.withOpacity(0.55), "P97"),
      ],
    );
  }

  Widget _legendChip(Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 20,
              height: 3,
              decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      );

  // ── Summary / percentile card ────────────────────────────────────────────

  Widget _summaryCard() {
    if (records.isEmpty) return const SizedBox.shrink();
    final latest = records.last;
    final month = (latest["month"] as num).toInt();
    final weight = (latest["weight"] as num).toDouble();
    final height = (latest["height"] as num).toDouble();

    // WHO clinical classifications
    final wWhoTerm = _WhoData.weightForAgeLabel(month, weight, _isBoy);
    final hWhoTerm = _WhoData.heightForAgeLabel(month, height, _isBoy);
    // Percentile band (secondary label)
    final wBand = _WhoData.weightPercentileLabel(month, weight, _isBoy);
    final hBand = _WhoData.heightPercentileLabel(month, height, _isBoy);

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
            "Latest Assessment — Month $month",
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 14),
          _percentileRow(
            icon: Icons.monitor_weight_outlined,
            label: "Weight",
            value: "${weight.toStringAsFixed(1)} kg",
            percentileLabel: wWhoTerm,
            bandLabel: wBand,
          ),
          const Divider(height: 20),
          _percentileRow(
            icon: Icons.height,
            label: "Height",
            value: "${height.toStringAsFixed(1)} cm",
            percentileLabel: hWhoTerm,
            bandLabel: hBand,
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
              "Percentiles show how your child compares to 100 children "
              "of the same age and gender. P50 is the median. "
              "P3–P97 is considered the normal range.",
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
    required String percentileLabel, // WHO clinical term e.g. "Stunted"
    required String bandLabel,       // Percentile band e.g. "P3–P15"
  }) {
    final color = _WhoData.percentileColor(percentileLabel);
    final advice = _WhoData.percentileInterpretation(percentileLabel);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("$label: ",
                      style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  Text(value,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  const Spacer(),
                  // Main WHO clinical badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      percentileLabel,
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Percentile band as secondary info
              Text(
                "Percentile: $bandLabel",
                style: TextStyle(
                    color: Colors.grey.shade600, fontSize: 11),
              ),
              const SizedBox(height: 3),
              // Clinical advice
              Text(advice, style: TextStyle(color: color, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

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
          labelColor: Colors.deepPurple,
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
                            color: Colors.deepPurple.withOpacity(0.3)),
                        const SizedBox(height: 20),
                        const Text(
                          "No growth data yet",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Once measurements are added, the growth chart "
                          "will appear here with WHO percentile bands.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 14),
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
                                borderRadius: BorderRadius.circular(14)),
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
                        // ── Summary + Percentile Card ─────────────────
                        _summaryCard(),
                        const SizedBox(height: 20),

                        // ── Chart Tabs ────────────────────────────────
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
                              _percentileLegend(),
                              const SizedBox(height: 4),
                              // Child line indicator
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Container(
                                      width: 24,
                                      height: 4,
                                      decoration: BoxDecoration(
                                          color: Colors.pinkAccent,
                                          borderRadius:
                                              BorderRadius.circular(2))),
                                  const SizedBox(width: 6),
                                  const Text("Your child",
                                      style: TextStyle(fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                height: 300,
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    _buildChart(
                                        type: "weight",
                                        childColor: Colors.pinkAccent),
                                    _buildChart(
                                        type: "height",
                                        childColor: Colors.deepPurple),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ── Records History ───────────────────────────
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
                          final month = (r["month"] as num).toInt();
                          final weight = (r["weight"] as num).toDouble();
                          final height = (r["height"] as num).toDouble();
                          // WHO clinical terms
                          final wLabel = _WhoData.weightForAgeLabel(month, weight, _isBoy);
                          final hLabel = _WhoData.heightForAgeLabel(month, height, _isBoy);
                          // Percentile bands
                          final wBand = _WhoData.weightPercentileLabel(month, weight, _isBoy);
                          final hBand = _WhoData.heightPercentileLabel(month, height, _isBoy);

                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14)),
                            margin:
                                const EdgeInsets.only(bottom: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text("Month $month",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _miniPercentileTile(
                                          "Weight",
                                          "${weight.toStringAsFixed(1)} kg",
                                          wLabel,
                                          wBand,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _miniPercentileTile(
                                          "Height",
                                          "${height.toStringAsFixed(1)} cm",
                                          hLabel,
                                          hBand,
                                        ),
                                      ),
                                    ],
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

  Widget _miniPercentileTile(
      String label, String value, String whoTerm, String bandLabel) {
    final color = _WhoData.percentileColor(whoTerm);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          // WHO clinical term badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
          // Percentile band as secondary
          Text(bandLabel,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
        ],
      ),
    );
  }
}