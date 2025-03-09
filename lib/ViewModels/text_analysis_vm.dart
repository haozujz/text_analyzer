import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_flutter/Services/logger_service.dart';
import 'package:nlp_flutter/Services/network_service.dart';

class TextAnalysisState {
  final String text;
  final bool isLoading;

  TextAnalysisState({this.text = '', this.isLoading = false});

  TextAnalysisState copyWith({String? text, bool? isLoading}) {
    return TextAnalysisState(
      text: text ?? this.text,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class TextAnalysisViewModel extends StateNotifier<TextAnalysisState> {
  TextAnalysisViewModel(super.state);

  void callLambdaFunction(String textInput) async {
    try {
      var result = await NetworkService().getTextAnalysis(textInput: textInput);
      LoggerService().info("Network Response: $result");
    } catch (e) {
      if (e is NetworkError) {
        LoggerService().error("Network error: ${e.message}");
        return;
      } else {
        LoggerService().error("Network Error calling AWS Lambda: $e");
      }
    }
  }
}
