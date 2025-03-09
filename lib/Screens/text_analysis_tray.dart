import 'package:flutter/material.dart';
import 'text_info_item.dart';
import 'sentiment_info_item.dart';
import 'entity_info_item.dart';
import 'key_phrase_info_item.dart';

class TextAnalysisTray extends StatelessWidget {
  final ScrollController scrollController;

  TextAnalysisTray({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      child: Container(
        color: Color(0xFF1C1C1E),
        width: double.infinity,
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 5,
                margin: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 255, 255, 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              TextInfoItem(),
              SizedBox(height: 12),
              SentimentInfoItem(),
              SizedBox(height: 12),
              EntityInfoItem(),
              SizedBox(height: 12),
              KeyPhraseInfoItem(),
              SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
