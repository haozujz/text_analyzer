// import 'package:flutter/material.dart';
import '../../Models/analysis_result_model.dart';
import 'text_info_item.dart';
import 'sentiment_info_item.dart';
import 'entity_info_item.dart';
import 'key_phrase_info_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ViewModels/text_analysis_vm.dart';
import '../../ViewModels/camera_vm.dart';
import 'package:flutter/cupertino.dart';

class TextAnalysisTray extends ConsumerWidget {
  final ScrollController scrollController;
  final AnalysisResult? analysisResult;

  const TextAnalysisTray({
    required this.scrollController,
    this.analysisResult,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textAnalysisState = ref.watch(textAnalysisViewModelProvider);
    final cameraState = ref.watch(cameraViewModelProvider);
    final result = analysisResult ?? textAnalysisState.analysisResult;

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
                opacity:
                    analysisResult != null
                        ? 1.0
                        : (cameraState.imagePath.isNotEmpty ? 1.0 : 0.0),
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

              TextInfoItem(text: result?.text ?? '...'),
              SizedBox(height: 12),
              if (result == null) ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CupertinoActivityIndicator(radius: 15),
                  ),
                ),
              ] else ...[
                SentimentInfoItem(sentimentAnalysis: result.sentiment),
                const SizedBox(height: 12),
                EntityInfoItem(entities: result.entities ?? []),
                const SizedBox(height: 12),
                KeyPhraseInfoItem(keyPhrases: result.keyPhrases ?? []),
              ],

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
