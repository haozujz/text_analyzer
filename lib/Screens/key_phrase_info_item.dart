import 'package:flutter/material.dart';

class KeyPhraseInfoItem extends StatelessWidget {
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
                  text: "KEY PHRASE ",
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
          // Dummy text boxes in column
          Column(
            children: [
              // Dummy box 1
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Key phrase 1: This is some dummy text for now.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'SF Pro Text',
                  ),
                ),
              ),

              SizedBox(height: 16),
              // Dummy box 2
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Key phrase 2: This is some more dummy text.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'SF Pro Text',
                  ),
                ),
              ),

              SizedBox(height: 16),
              // Dummy box 3
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Key phrase 3: Here’s yet another dummy text.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'SF Pro Text',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
