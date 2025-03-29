import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_flutter/Models/analysis_result_model.dart';
import 'package:nlp_flutter/Screens/ListResults/analysis_result_image_screen.dart';
import '../../Utilities/constants.dart';
import '../TextAnalysis/text_analysis_tray.dart';

class AnalysisResultDetail extends ConsumerStatefulWidget {
  final AnalysisResult analysisResult;

  const AnalysisResultDetail({super.key, required this.analysisResult});

  @override
  ConsumerState<AnalysisResultDetail> createState() =>
      _AnalysisResultDetailState();
}

class _AnalysisResultDetailState extends ConsumerState<AnalysisResultDetail> {
  final DraggableScrollableController _scrollController =
      DraggableScrollableController();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    //final authState = ref.watch(authViewModelProvider);

    const double minChildSize = 0.2;
    const double initialChildSize = 0.6;
    const double maxChildSize = 0.9;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnalysisResultImageScreen(
              analysisResult: widget.analysisResult,
            ),
          ),

          // Draggable Tray
          SizedBox(
            height: screenHeight,
            child: DraggableScrollableSheet(
              controller: _scrollController,
              initialChildSize: initialChildSize,
              minChildSize: minChildSize,
              maxChildSize: maxChildSize,
              builder: (context, scrollController) {
                return TextAnalysisTray(
                  scrollController: scrollController,
                  analysisResult: widget.analysisResult,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
