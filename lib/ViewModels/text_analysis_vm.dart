import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_flutter/Repos/analysis_result_repo.dart';
import '../Models/analysis_result_model.dart';
import 'package:nlp_flutter/Services/logger_service.dart';
import 'package:nlp_flutter/Services/network_service.dart';
import '../Services/ocr_service.dart';
import 'package:uuid/uuid.dart';

import '../Services/storage_service.dart';
import '../Services/websocket.dart';
import '../Utilities/jpg_converter.dart';

// Provides an instance of WebSocketService
final webSocketProvider = Provider((ref) => WebSocketService());

// Provides a stream of messages received from WebSocket
final webSocketStreamProvider = StreamProvider<String>((ref) {
  return ref.watch(webSocketProvider).messages;
});

final textAnalysisViewModelProvider =
    StateNotifierProvider<TextAnalysisViewModel, TextAnalysisState>(
      (ref) => TextAnalysisViewModel(ref),
    );

class TextAnalysisState {
  final String text;
  final AnalysisResult? analysisResult;
  final bool isLoading;
  final bool isTextAnalysisVisible;
  final List<AnalysisResult> storedAnalysisResults;

  TextAnalysisState({
    this.text = '...',
    this.analysisResult,
    this.isLoading = false,
    this.isTextAnalysisVisible = true,
    this.storedAnalysisResults = const [],
  });

  TextAnalysisState copyWith({
    String? text,
    AnalysisResult? analysisResult,
    bool? isLoading,
    bool? isTextAnalysisVisible,
    List<AnalysisResult>? storedAnalysisResults,
  }) {
    return TextAnalysisState(
      text: text ?? this.text,
      analysisResult: analysisResult,
      isLoading: isLoading ?? this.isLoading,
      isTextAnalysisVisible:
          isTextAnalysisVisible ?? this.isTextAnalysisVisible,
      storedAnalysisResults:
          storedAnalysisResults ?? this.storedAnalysisResults,
    );
  }
}

class TextAnalysisViewModel extends StateNotifier<TextAnalysisState> {
  final Ref ref;

  TextAnalysisViewModel(this.ref) : super(TextAnalysisState()) {
    listenToWebSocket();
    cleanOrphanedData();
  }

  void listenToWebSocket() {
    final webSocketService = ref.read(webSocketProvider);

    webSocketService.messages.listen((message) {
      try {
        final Map<String, dynamic> decodedMessage = jsonDecode(message);
        if (decodedMessage.containsKey('item')) {
          AnalysisResult newResult = AnalysisResultRepository()
              .parseAnalysisResultFromWebSocket(decodedMessage['item']);

          var newList = state.storedAnalysisResults;

          if (decodedMessage.containsKey('action')) {
            if (decodedMessage['action'] == 'DELETE') {
              newList.removeWhere((element) => element.id == newResult.id);
            } else if (decodedMessage['action'] == 'INSERT') {
              newList.add(newResult);
            }
          }

          state = state.copyWith(
            storedAnalysisResults: newList,
            analysisResult: state.analysisResult,
          );
        }
      } catch (e) {
        LoggerService().error("Error parsing WebSocket message: $e");
      }
    });
  }

  Future<void> onPhotoChange(String imagePath, String user) async {
    state = state.copyWith(text: '...');

    if (imagePath.isEmpty) {
      return;
    }

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

    if (text.isEmpty) {
      text = '...';
    }

    state = state.copyWith(text: text);

    if (state.text.isNotEmpty && state.text != '...') {
      try {
        var resp = await getTextAnalysisJSON();
        interpretTextAnalysisJSON(resp, user, imagePath);
      } catch (e) {
        rethrow;
      }
    }
  }

  String replaceNewlinesWithTwoSpaces(String inputText) {
    return inputText.replaceAll('\n', '  ');
  }

  Future<Map<String, dynamic>> getTextAnalysisJSON() async {
    String modifiedText = replaceNewlinesWithTwoSpaces(state.text);

    try {
      var result = await NetworkService().fetchTextAnalysis(
        textInput: modifiedText,
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

  // From AWS Comprehend
  void interpretTextAnalysisJSON(
    Map<String, dynamic> body,
    String user,
    String imagePath,
  ) {
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

    List<Map<String, dynamic>> entitySentiments =
        List<Map<String, dynamic>>.from(body['entity_sentiments'] ?? []);

    List<String> keyPhrases = List<String>.from(body['key_phrases'] ?? []);

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
      user: user,
      id: Uuid().v4(),
      text: text,
      language: language,
      sentiment: newSentiment,
      entities: newEntitySentiments,
      keyPhrases: keyPhrases,
      imageId: '',
      imagePath: imagePath,
      createdAt: DateTime.now().toUtc(),
    );

    state = state.copyWith(analysisResult: x);
  }

  void toggleTextAnalysis([bool? isVisible]) {
    state = state.copyWith(
      isTextAnalysisVisible: isVisible ?? !state.isTextAnalysisVisible,
      analysisResult: state.analysisResult,
    );
  }

  Future<void> postAnalysisResult() async {
    try {
      // Add item to cloud
      if (state.analysisResult != null) {
        await AnalysisResultRepository().postAnalysisResult(
          analysisResult: state.analysisResult!,
        );
      } else {
        throw NetworkError.badRequest;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAnalysisResult({
    required String user,
    required String id,
  }) async {
    // Remove local item
    var newList = state.storedAnalysisResults;
    newList.removeWhere((element) => element.id == id);

    state = state.copyWith(
      storedAnalysisResults: newList,
      analysisResult: state.analysisResult,
    );

    // Remove cloud item
    try {
      await AnalysisResultRepository().deleteAnalysisResult(user: user, id: id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> emptyStoredAnalysisResults() async {
    state = state.copyWith(
      storedAnalysisResults: [],
      analysisResult: state.analysisResult,
    );
  }

  Future<void> fetchAnalysisResults(String user) async {
    try {
      var parsedResults = await AnalysisResultRepository().fetchAnalysisResults(
        user,
      );

      state = state.copyWith(
        storedAnalysisResults: parsedResults,
        analysisResult: state.analysisResult,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadImage({required String identityId}) async {
    try {
      if (state.analysisResult == null ||
          state.analysisResult!.imagePath.isEmpty) {
        throw NetworkError.unknown;
      }
      String newImagePath = await ImageUtils.ensureJpegFormat(
        state.analysisResult!.imagePath,
      );
      final imageId = Uuid().v4();

      await StorageService().uploadFile(
        imagePath: newImagePath,
        imageId: imageId,
        identityId: identityId,
      );

      var newAnalysisResult = AnalysisResult(
        user: state.analysisResult!.user,
        id: state.analysisResult!.id,
        text: state.analysisResult!.text,
        language: state.analysisResult!.language,
        sentiment: state.analysisResult!.sentiment,
        entities: state.analysisResult!.entities,
        keyPhrases: state.analysisResult!.keyPhrases,
        imageId: imageId,
        imagePath: state.analysisResult!.imagePath,
        createdAt: state.analysisResult!.createdAt,
      );

      state = state.copyWith(analysisResult: newAnalysisResult);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cleanOrphanedData() async {
    try {
      final result = await AnalysisResultRepository().cleanOrphanedResults();
      LoggerService().info('Cleaned orphaned data $result');
    } catch (e) {
      LoggerService().error('Error on cleaning zombie data: $e');
    }
  }
}
