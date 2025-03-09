import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MiniDonutChart extends StatelessWidget {
  final double positive; // Positive percentage value

  MiniDonutChart({required this.positive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0), // Reduce padding for the mini version
      child: Stack(
        alignment: Alignment.center, // Center the text
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0, // Space between each section
              centerSpaceRadius: 20, // Reduced center radius for a smaller ring
              sections: [
                PieChartSectionData(
                  value: positive,
                  color: Color(0xFF34C759), // iOS Green
                  radius: 16, // Reduced radius for smaller ring
                  showTitle: false, // Disable titles
                ),
                PieChartSectionData(
                  value: 100 - positive,
                  color: Colors.grey[800], // Transparent white for the rest
                  radius: 16, // Reduced radius for smaller ring
                  showTitle: false, // Disable titles
                ),
              ],
            ),
          ),
          // Display the percentage in the center
          Text(
            '${(positive).toStringAsFixed(0)}%', // Show the percentage rounded to the nearest integer
            style: TextStyle(
              fontSize: 14, // Reduced font size for the mini version
              fontWeight: FontWeight.bold,
              fontFamily: 'SF Pro Text',
              color: Colors.white, // White color for contrast
            ),
          ),
        ],
      ),
    );
  }
}
