import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DonutChart extends StatelessWidget {
  final double positive; // Positive percentage value
  final double negative; // Negative percentage value
  final double neutral; // Neutral percentage value
  final double mixed; // Mixed percentage value

  const DonutChart({
    super.key,
    required this.positive,
    required this.negative,
    required this.neutral,
    required this.mixed,
  });

  @override
  Widget build(BuildContext context) {
    // Find the highest percentage score
    double highest = [
      positive,
      negative,
      neutral,
      mixed,
    ].reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        alignment: Alignment.center, // Center the text
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0, // Space between each section
              centerSpaceRadius:
                  36, // Reduced center radius to make the ring slimmer
              sections: [
                PieChartSectionData(
                  value: positive,
                  color: Color(0xFF34C759), // iOS Green
                  radius: 24, // Reduced radius for slimmer ring (3/5 of 40)
                  showTitle: false, // Disable titles
                ),
                PieChartSectionData(
                  value: negative,
                  color: Color(0xFFFF3B30), // iOS Red
                  radius: 24, // Reduced radius for slimmer ring (3/5 of 40)
                  showTitle: false, // Disable titles
                ),
                PieChartSectionData(
                  value: neutral,
                  color: Color(0xFF8E8E93), // iOS Grey
                  radius: 24, // Reduced radius for slimmer ring (3/5 of 40)
                  showTitle: false, // Disable titles
                ),
                PieChartSectionData(
                  value: mixed,
                  color: Color(0xFFFF9500), // iOS Orange
                  radius: 24, // Reduced radius for slimmer ring (3/5 of 40)
                  showTitle: false, // Disable titles
                ),
              ],
            ),
          ),

          Text(
            '${(highest).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'SF Pro Text',
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
