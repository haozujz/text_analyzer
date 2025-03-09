import 'package:flutter/material.dart';
import '../Views/mini_donut_chart.dart'; // Assuming you already have a MiniDonutChart widget

class EntityInfoItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.85, // 85% of screen width
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align left
        children: [
          // Title with underline starting from the right
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 16, color: Colors.white),
              children: [
                TextSpan(
                  text: "ENTITY ",
                  style: TextStyle(
                    fontFamily: 'SF Pro Text',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: "DETECTION",
                  style: TextStyle(fontFamily: 'SF Pro Text'),
                ),
              ],
            ),
          ),
          SizedBox(height: 4),
          Stack(
            alignment: Alignment.centerRight,
            children: [
              Container(
                width:
                    30, // Adjust this to make the underline shorter or longer
                height: 2,
                color: Colors.white,
              ),
            ],
          ),
          SizedBox(height: 26), // Spacing between title and container
          // Column of row items
          Column(
            children: [
              // Item 1 with text box and mini donut chart
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment:
                    CrossAxisAlignment
                        .center, // Align children vertically in the center
                children: [
                  // Text Box
                  Container(
                    width:
                        screenWidth * 0.5, // Text box takes up half the width
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Entity 1: This is some dummy text for now.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'SF Pro Text',
                      ),
                    ),
                  ),
                  // Mini Donut Chart
                  SizedBox(
                    height: 80, // Mini donut chart height
                    width: 80, // Mini donut chart width
                    child: MiniDonutChart(
                      positive: 65.0,
                    ), // Example with 65% positive
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Item 2 with text box and mini donut chart
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Text Box
                  Container(
                    width:
                        screenWidth * 0.5, // Text box takes up half the width
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Entity 2: More dummy text here.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'SF Pro Text',
                      ),
                    ),
                  ),
                  // Mini Donut Chart
                  SizedBox(
                    height: 80, // Mini donut chart height
                    width: 80, // Mini donut chart width
                    child: MiniDonutChart(
                      positive: 80.0,
                    ), // Example with 80% positive
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Item 3 with text box and mini donut chart
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Text Box
                  Container(
                    width:
                        screenWidth * 0.5, // Text box takes up half the width
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Entity 3: Here’s another dummy text.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'SF Pro Text',
                      ),
                    ),
                  ),
                  // Mini Donut Chart
                  SizedBox(
                    height: 80, // Mini donut chart height
                    width: 80, // Mini donut chart width
                    child: MiniDonutChart(
                      positive: 45.0,
                    ), // Example with 45% positive
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
