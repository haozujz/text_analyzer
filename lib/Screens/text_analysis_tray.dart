import 'package:flutter/material.dart';
import 'text_info_item.dart';
import 'sentiment_info_item.dart';
import 'entity_info_item.dart';
import 'key_phrase_info_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ViewModels/text_analysis_vm.dart';
import '../ViewModels/camera_vm.dart';
import 'package:flutter/cupertino.dart';

class TextAnalysisTray extends ConsumerWidget {
  final ScrollController scrollController;

  const TextAnalysisTray({required this.scrollController, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textAnalysisState = ref.watch(textAnalysisViewModelProvider);
    final cameraState = ref.watch(cameraViewModelProvider);

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
              AnimatedOpacity(
                duration: Duration(
                  milliseconds: 300,
                ), // Adjust for smoother animation
                opacity: cameraState.imagePath.isNotEmpty ? 1.0 : 0.0,
                child: Container(
                  width: 36,
                  height: 5,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              TextInfoItem(text: textAnalysisState.text),
              SizedBox(height: 12),
              if (textAnalysisState.analysisResult == null) ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CupertinoActivityIndicator(
                      radius: 15, // Apple-style spinner size
                    ),
                  ),
                ),
              ] else ...[
                SentimentInfoItem(
                  sentimentAnalysis:
                      textAnalysisState.analysisResult?.sentiment,
                ),
                SizedBox(height: 12),
                EntityInfoItem(
                  entities: textAnalysisState.analysisResult?.entities ?? [],
                ),
                SizedBox(height: 12),
                KeyPhraseInfoItem(
                  keyPhrases:
                      textAnalysisState.analysisResult?.keyPhrases ?? [],
                ),
              ],

              SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
