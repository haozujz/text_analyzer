import 'package:flutter/material.dart';
import '../../Utilities/constants.dart';
//import '../Views/mini_donut_chart.dart';
import '../../Models/analysis_result_model.dart';

class EntityInfoItem extends StatelessWidget {
  final List<EntitySentiment> entities;

  const EntityInfoItem({super.key, required this.entities});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.85,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            children: [Container(width: 30, height: 2, color: AppColors.text)],
          ),
          SizedBox(height: 26),

          Column(
            children: [
              for (int i = 0; i < entities.length; i++) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: screenWidth * 0.55,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        entities[i].text,
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 14,
                          fontFamily: 'SF Pro Text',
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      width: 70,
                      child: Icon(
                        _getSentimentIcon(entities[i].sentiment),
                        color: _getSentimentColor(entities[i].sentiment),
                        size: 40,
                      ),
                    ),
                  ],
                ),
                if (i != entities.length - 1) SizedBox(height: 16),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

IconData _getSentimentIcon(String sentiment) {
  switch (sentiment) {
    case 'positive':
      return Icons.thumb_up;
    case 'negative':
      return Icons.thumb_down;
    case 'neutral':
      return Icons.sentiment_neutral;
    case 'mixed':
      return Icons.thumbs_up_down;
    default:
      return Icons.help;
  }
}

Color _getSentimentColor(String sentiment) {
  switch (sentiment) {
    case 'positive':
      return Color(0xFF34C759);
    case 'negative':
      return Color(0xFFFF3B30);
    case 'neutral':
      return Color(0xFF8E8E93);
    case 'mixed':
      return Color(0xFF34C759);
    default:
      return Colors.grey;
  }
}




              //     Container(
              //       width:
              //           screenWidth * 0.55, // Text box takes up half the width
              //       padding: EdgeInsets.all(16),
              //       decoration: BoxDecoration(
              //         color: Color(0xFF1C1C1E),
              //         borderRadius: BorderRadius.circular(12),
              //       ),
              //       child: Text(
              //         'Entity 1: This is some dummy text for now.',
              //         style: TextStyle(
              //           color: Colors.white,
              //           fontSize: 14,
              //           fontFamily: 'SF Pro Text',
              //         ),
              //       ),
              //     ),

              //     SizedBox(
              //       height: 80,
              //       width: 80,
              //       child: Icon(
              //         Icons.thumb_up,
              //         color: Color(0xFF34C759),
              //         size: 40,
              //       ),
              //     ),
              //   ],
              // ),

              // SizedBox(height: 16),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     // Text Box
              //     Container(
              //       width:
              //           screenWidth * 0.5, // Text box takes up half the width
              //       padding: EdgeInsets.all(16),
              //       decoration: BoxDecoration(
              //         color: Color(0xFF1C1C1E),
              //         borderRadius: BorderRadius.circular(12),
              //       ),
              //       child: Text(
              //         'Entity 2: More dummy text here.',
              //         style: TextStyle(
              //           color: Colors.white,
              //           fontSize: 14,
              //           fontFamily: 'SF Pro Text',
              //         ),
              //       ),
              //     ),
              //     // Mini Donut Chart
              //     SizedBox(
              //       height: 80, // Mini donut chart height
              //       width: 80, // Mini donut chart width
              //       child: MiniDonutChart(
              //         positive: 80.0,
              //       ), // Example with 80% positive
              //     ),
              //   ],
              // ),
              // SizedBox(height: 16),

              // // Item 3 with text box and mini donut chart
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     // Text Box
              //     Container(
              //       width:
              //           screenWidth * 0.5, // Text box takes up half the width
              //       padding: EdgeInsets.all(16),
              //       decoration: BoxDecoration(
              //         color: Color(0xFF1C1C1E),
              //         borderRadius: BorderRadius.circular(12),
              //       ),
              //       child: Text(
              //         'Entity 3: Here’s another dummy text.',
              //         style: TextStyle(
              //           color: Colors.white,
              //           fontSize: 14,
              //           fontFamily: 'SF Pro Text',
              //         ),
              //       ),
              //     ),
              //     // Mini Donut Chart
              //     SizedBox(
              //       height: 80, // Mini donut chart height
              //       width: 80, // Mini donut chart width
              //       child: MiniDonutChart(
              //         positive: 45.0,
              //       ), // Example with 45% positive
              //     ),
              //],
              //),