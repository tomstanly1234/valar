import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GrowthPercentileChart extends StatelessWidget {
  final int ageMonths;
  final double weight;

  const GrowthPercentileChart({
    super.key,
    required this.ageMonths,
    required this.weight,
  });

  // Simulated WHO percentile curves (smooth realistic approximation)
  List<FlSpot> generateCurve(double base, double slope) {
    return List.generate(
      61,
      (i) => FlSpot(i.toDouble(), base + (slope * i)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p3 = generateCurve(2.5, 0.20);
    final p15 = generateCurve(2.8, 0.23);
    final p50 = generateCurve(3.2, 0.27);
    final p85 = generateCurve(3.6, 0.31);
    final p97 = generateCurve(4.0, 0.35);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withOpacity(0.08),
          )
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Weight-for-Age Growth Chart",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 60,
                minY: 2,
                maxY: 25,
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                ),
                lineBarsData: [
                  percentileLine(p3, Colors.red.shade300),
                  percentileLine(p15, Colors.orange),
                  percentileLine(p50, Colors.green),
                  percentileLine(p85, Colors.blue),
                  percentileLine(p97, Colors.purple),

                  // Child point
                  LineChartBarData(
                    spots: [
                      FlSpot(ageMonths.toDouble(), weight),
                    ],
                    isCurved: false,
                    barWidth: 0,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter:
                          (spot, percent, barData, index) =>
                              FlDotCirclePainter(
                        radius: 6,
                        color: Colors.black,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Percentiles: 3rd | 15th | 50th | 85th | 97th",
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  LineChartBarData percentileLine(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 2,
      dotData: FlDotData(show: false),
    );
  }
}