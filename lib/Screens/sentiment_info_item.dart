import 'package:flutter/material.dart';
import '../Views/donut_chart.dart';

class SentimentInfoItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.85, // 80% of screen width
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align left
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 16, color: Colors.white),
              children: [
                TextSpan(
                  text: "SENTIMENT ",
                  style: TextStyle(
                    fontFamily: 'SF Pro Text',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: "ANALYSIS",
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
          // Row layout for donut chart, symbols, and key
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Distribute space evenly
              children: [
                // Donut Chart
                SizedBox(
                  height: 100, // Reduced height for the donut chart
                  width: 100, // Width to fit chart within the row
                  child: DonutChart(
                    positive: 45.0,
                    negative: 25.0,
                    neutral: 15.0,
                    mixed: 15.0,
                  ),
                ),

                // Thumbs Up/Down/Neutral Icons
                Column(
                  children: [
                    Icon(
                      Icons.thumb_up,
                      color: Color(0xFF34C759),
                      size: 40,
                    ), // Green for positive
                    // SizedBox(height: 8), // Space between icons
                    // Icon(
                    //   Icons.thumb_down,
                    //   color: Color(0xFFFF3B30),
                    // ), // Red for negative
                    // SizedBox(height: 8),
                    // Icon(
                    //   Icons.remove,
                    //   color: Color(0xFF8E8E93),
                    // ), // Grey for neutral
                  ],
                ),

                // Chart Key Column for Colors
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align key vertically
                  children: [
                    // Positive
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Color(0xFF34C759),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Positive', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Negative
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Color(0xFFFF3B30),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Negative', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Neutral
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Color(0xFF8E8E93),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Neutral', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Mixed
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Color(0xFFFF9500),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Mixed', style: TextStyle(color: Colors.white)),
                      ],
                    ),

                    SizedBox(height: 4),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
