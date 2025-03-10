import 'package:flutter/material.dart';

class TextInfoItem extends StatelessWidget {
  final String text;

  const TextInfoItem({super.key, required this.text});

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
                  text: "TEXT ",
                  style: TextStyle(
                    fontFamily: 'SF Pro Text',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: "EXTRACTION",
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
          // Dummy text box with padding
          Container(
            padding: EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'SF Pro Text',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
