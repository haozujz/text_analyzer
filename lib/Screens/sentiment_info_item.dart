import 'package:flutter/material.dart';
import '../Views/donut_chart.dart';
import '../Models/analysis_result_model.dart';

class SentimentInfoItem extends StatelessWidget {
  final SentimentAnalysis? sentimentAnalysis;

  const SentimentInfoItem({super.key, this.sentimentAnalysis});

  // Computed value for the highest sentiment type
  String get highestSentiment {
    if (sentimentAnalysis == null) {
      return 'neutral';
    }

    Map<String, double> sentimentMap = {
      'positive': sentimentAnalysis?.positive ?? 0.0,
      'negative': sentimentAnalysis?.negative ?? 0.0,
      'neutral': sentimentAnalysis?.neutral ?? 0.0,
      'mixed': sentimentAnalysis?.mixed ?? 0.0,
    };

    // Sort the map by value and get the key with the highest value
    var highest = sentimentMap.entries.reduce(
      (curr, next) => curr.value > next.value ? curr : next,
    );

    return highest.key;
  }

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
                    positive: sentimentAnalysis?.positive ?? 25.0,
                    negative: sentimentAnalysis?.negative ?? 25.0,
                    neutral: sentimentAnalysis?.neutral ?? 25.0,
                    mixed: sentimentAnalysis?.mixed ?? 25.0,
                  ),
                ),

                // Thumbs Up/Down/Neutral Icons
                Column(
                  children: [
                    Builder(
                      builder: (context) {
                        Icon getSentimentIcon(String sentiment) {
                          switch (sentiment) {
                            case 'positive':
                              return Icon(
                                Icons.thumb_up,
                                color: Color(0xFF34C759),
                                size: 40,
                              );
                            case 'negative':
                              return Icon(
                                Icons.thumb_down,
                                color: Color(0xFFFF3B30),
                                size: 40,
                              );
                            case 'neutral':
                              return Icon(
                                Icons.sentiment_neutral,
                                color: Color(0xFF8E8E93),
                                size: 40,
                              );
                            case 'mixed':
                              return Icon(
                                Icons.thumbs_up_down,
                                color: Color(0xFF34C759),
                                size: 40,
                              );
                            default:
                              return Icon(
                                Icons.help,
                                color: Colors.grey,
                                size: 40,
                              ); // Default icon in case of undefined sentiment
                          }
                        }

                        return getSentimentIcon(highestSentiment);
                      },
                    ),
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
