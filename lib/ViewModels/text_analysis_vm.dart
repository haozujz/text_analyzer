import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Models/analysis_result_model.dart';
import 'package:nlp_flutter/Services/logger_service.dart';
import 'package:nlp_flutter/Services/network_service.dart';
import '../Services/ocr_service.dart';
//import 'dart:convert';
import 'package:uuid/uuid.dart';

final textAnalysisViewModelProvider =
    StateNotifierProvider<TextAnalysisViewModel, TextAnalysisState>(
      (ref) => TextAnalysisViewModel(),
    );

class TextAnalysisState {
  final String text;
  final AnalysisResult? analysisResult;
  final bool isLoading;

  TextAnalysisState({
    this.text = '...',
    this.analysisResult,
    this.isLoading = false,
  });

  TextAnalysisState copyWith({
    String? text,
    AnalysisResult? analysisResult,
    bool? isLoading,
  }) {
    return TextAnalysisState(
      text: text ?? this.text,
      analysisResult: analysisResult,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class TextAnalysisViewModel extends StateNotifier<TextAnalysisState> {
  TextAnalysisViewModel() : super(TextAnalysisState());

  void onNewPhotoTaken(String imagePath) async {
    String text = '...';

    try {
      text = await OCRService().performOCR(imagePath);
      LoggerService().info('Extracted text: $text');
    } catch (e) {
      if (e is OCRError) {
        LoggerService().error('OCRError: $e.mesage');
      } else {
        LoggerService().error('OCRError: $e');
      }
    }

    state = state.copyWith(text: text);
    if (state.text.isNotEmpty && state.text != '...') {
      var resp = await getTextAnalysisJSON();
      interpretTextAnalysisJSON(resp);
    }
  }

  // String replaceNewlinesWithSpaces(String inputText) {
  //   return inputText.replaceAll('\n', ' ');
  // }

  Future<Map<String, dynamic>> getTextAnalysisJSON() async {
    //String modifiedText = replaceNewlinesWithSpaces(state.text);

    try {
      var result = await NetworkService().fetchTextAnalysis(
        textInput: state.text,
      );
      LoggerService().info("Network Response: $result");
      return result;
    } catch (e) {
      if (e is NetworkError) {
        LoggerService().error("Network error calling AWS Lambda: ${e.message}");
      } else {
        LoggerService().error("Network Error calling AWS Lambda: $e");
      }
      rethrow;
    }
  }

  void interpretTextAnalysisJSON(Map<String, dynamic> body) {
    if (body.isEmpty) {
      LoggerService().error('Error: Response is empty');
      return;
    }

    // Access text and language
    String text = body['text'] ?? 'No text available';
    String language = body['language'] ?? 'No language available';

    // Access sentiment data
    String sentiment =
        body['sentiment']?['Sentiment'] ?? 'No sentiment available';
    Map<String, double> sentimentScores = {
      'Positive': body['sentiment']?['SentimentScores']?['Positive'] ?? 0.0,
      'Negative': body['sentiment']?['SentimentScores']?['Negative'] ?? 0.0,
      'Neutral': body['sentiment']?['SentimentScores']?['Neutral'] ?? 0.0,
      'Mixed': body['sentiment']?['SentimentScores']?['Mixed'] ?? 0.0,
    };

    // Access entity_sentiments
    List<Map<String, dynamic>> entitySentiments =
        List<Map<String, dynamic>>.from(body['entity_sentiments'] ?? []);

    // Access key_phrases
    List<String> keyPhrases = List<String>.from(body['key_phrases'] ?? []);

    // Output values

    print('Text: $text');
    print('Language: $language');
    print('Sentiment: $sentiment');
    print('Sentiment Scores: $sentimentScores');
    print('Entity Sentiments: $entitySentiments');
    print('Key Phrases: $keyPhrases');

    SentimentAnalysis newSentiment = SentimentAnalysis(
      sentiment: sentiment.toLowerCase(),
      positive: sentimentScores['Positive'] ?? 0.0,
      negative: sentimentScores['Negative'] ?? 0.0,
      neutral: sentimentScores['Neutral'] ?? 0.0,
      mixed: sentimentScores['Mixed'] ?? 0.0,
    );

    List<EntitySentiment> newEntitySentiments = [];

    for (var entity in entitySentiments) {
      EntitySentiment x = EntitySentiment(
        type: entity['Type'].toLowerCase() ?? '',
        text: entity['Text'] ?? '',
        sentiment: entity['Sentiment'].toLowerCase() ?? '',
      );
      newEntitySentiments.add(x);
    }

    AnalysisResult x = AnalysisResult(
      id: Uuid().v4(),
      text: text,
      language: language,
      sentiment: newSentiment,
      entities: newEntitySentiments,
      keyPhrases: keyPhrases,
    );

    state = state.copyWith(analysisResult: x);
  }
}
//   void interpretTextAnalysis(String resp) {

//   //   final responseJson = '''{
//   //   "statusCode": 200,
//   //   "body": {
//   //     "text": "I love this app! The name of this app is Text Sentiment Analyzer.",
//   //     "language": "en",
//   //     "sentiment": {
//   //       "Sentiment": "POSITIVE",
//   //       "SentimentScores": {
//   //         "Positive": 99.98713731765747,
//   //         "Negative": 0.0030144743504934013,
//   //         "Neutral": 0.006908029172336683,
//   //         "Mixed": 0.0029376653401413932
//   //       }
//   //     },
//   //     "entity_sentiments": [
//   //       {
//   //         "Score": 0.598901093006134,
//   //         "Type": "OTHER",
//   //         "Text": "Sentiment Analyzer"
//   //       }
//   //     ],
//   //     "key_phrases": [
//   //       "this app",
//   //       "The name",
//   //       "this app",
//   //       "Text Sentiment Analyzer"
//   //     ]
//   //   },
//   //   "headers": {
//   //     "Content-Type": "application/json"
//   //   }
//   // }''';

//     final response = json.decode(resp);

//     // Accessing the body
//     final body = response['body'];

//     // Access text and language
//     String text = body['text'];
//     String language = body['language'];

//     // Access sentiment data
//     String sentiment = body['sentiment']['Sentiment'];
//     Map<String, double> sentimentScores = {
//       'Positive': body['sentiment']['SentimentScores']['Positive'],
//       'Negative': body['sentiment']['SentimentScores']['Negative'],
//       'Neutral': body['sentiment']['SentimentScores']['Neutral'],
//       'Mixed': body['sentiment']['SentimentScores']['Mixed'],
//     };

//     // Access entity_sentiments
//     List<Map<String, dynamic>> entitySentiments =
//         List<Map<String, dynamic>>.from(body['entity_sentiments']);

//     // Access key_phrases
//     List<String> keyPhrases = List<String>.from(body['key_phrases']);

//     // Output values
//     print('Text: $text');
//     print('Language: $language');
//     print('Sentiment: $sentiment');
//     print('Sentiment Scores: $sentimentScores');
//     print('Entity Sentiments: $entitySentiments');
//     print('Key Phrases: $keyPhrases');
//   }
// }
