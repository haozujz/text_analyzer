// import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
// import 'package:uuid/uuid.dart';
// import '../Models/analysis_result_model.dart';

import 'package:nlp_flutter/Services/logger_service.dart';

import '../Models/analysis_result_model.dart';

class AnalysisResultRepository {
  AnalysisResult parseAnalysisResult(Map<String, dynamic> item) {
    try {
      // Parse sentiment data
      LoggerService().info('Parsing: ${item['sentiment']}');
      LoggerService().info('Parsing: ${item['entities']}');

      // final sentimentData =
      //     item['sentiment'] ??
      //     SentimentAnalysis(
      //       sentiment: '',
      //       positive: 0.0,
      //       negative: 0.0,
      //       neutral: 0.0,
      //       mixed: 0.0,
      //     ); // Default to empty map if missing
      // final sentiment = SentimentAnalysis(
      //   sentiment: sentimentData['sentiment'] ?? 'neutral',
      //   positive: 0.0,
      //   negative: 0.0,
      //   neutral: 0.0,
      //   mixed: 0.0,
      // );

      final sentiment = SentimentAnalysis(
        sentiment: item['sentiment']['sentiment'] ?? 'neutral',
        positive:
            double.tryParse(
              item['sentiment']['positive']?.toString() ?? '0.0',
            ) ??
            0.0,
        negative:
            double.tryParse(
              item['sentiment']['negative']?.toString() ?? '0.0',
            ) ??
            0.0,
        neutral:
            double.tryParse(
              item['sentiment']['neutral']?.toString() ?? '0.0',
            ) ??
            0.0,
        mixed:
            double.tryParse(item['sentiment']['mixed']?.toString() ?? '0.0') ??
            0.0,
      );

      // Parse entities (check if entities exists and map through them)
      final entitiesData =
          (item['entities'] is List ? item['entities'] : [])
              .map((e) {
                final entity = e is Map ? e : {}; // Ensure entity is a Map
                return EntitySentiment(
                  text: entity['text'] ?? '',
                  type: entity['type'] ?? '',
                  sentiment: entity['sentiment'] ?? '',
                );
              })
              .toList()
              .cast<EntitySentiment>();

      // Parse keyPhrases (check if keyPhrases exists and map through them)
      final keyPhrases =
          (item['keyPhrases'] is List ? item['keyPhrases'] : []).map<String>((
            e,
          ) {
            if (e is String) {
              return e; // If the element is a String, use it
            } else {
              return ''; // Otherwise, return an empty string or handle it accordingly
            }
          }).toList(); // This explicitly maps each element to a String

      //TODO: Fix createdAt parsing

      final createdAt =
          item['createdAt'] != null
              ? DateTime.tryParse(item['createdAt']) ?? DateTime.now()
              : DateTime.now();

      // Return the parsed AnalysisResult
      return AnalysisResult(
        user: item['user'] ?? 'someUser',
        id: item['id'] ?? 'someId',
        text: item['text'] ?? 'someText',
        language: item['language'] ?? 'en',
        sentiment: sentiment,
        entities: entitiesData,
        keyPhrases: keyPhrases,
        imageId: item['imageId'] ?? '',
        imagePath: item['imagePath'] ?? '',
        createdAt: createdAt,
      );
    } catch (e) {
      rethrow; // Optional: rethrow or handle based on your use case
    }
  }

  AnalysisResult parseAnalysisResultFromWebSocket(Map<String, dynamic> item) {
    return AnalysisResult(
      id: item['id']['S'] ?? '',
      user: item['user']['S'] ?? '',
      text: item['text']['S'] ?? '',
      language: item['language']['S'] ?? '',
      createdAt: DateTime.parse(item['createdAt']['S']),
      sentiment: parseSentiment(item['sentiment']['M']),
      keyPhrases: parseKeyPhrases(item['keyPhrases']['L']),
      entities: parseEntities(item['entities']['L']),
      imageId: item['imageId']['S'] ?? '',
      imagePath: item['imagePath']['S'] ?? '',
    );
  }

  // From WebSocket
  SentimentAnalysis parseSentiment(Map<String, dynamic> sentimentMap) {
    return SentimentAnalysis(
      sentiment: sentimentMap['sentiment']['S'].toLowerCase(),
      positive: double.tryParse(sentimentMap['positive']['N']) ?? 0.0,
      negative: double.tryParse(sentimentMap['negative']['N']) ?? 0.0,
      neutral: double.tryParse(sentimentMap['neutral']['N']) ?? 0.0,
      mixed: double.tryParse(sentimentMap['mixed']['N']) ?? 0.0,
    );
  }

  List<String> parseKeyPhrases(List<dynamic> keyPhrasesList) {
    return keyPhrasesList.map((item) => item['S'] as String).toList();
  }

  List<EntitySentiment> parseEntities(List<dynamic> entitiesList) {
    return entitiesList.map((entity) {
      final entityMap = entity['M'];
      return EntitySentiment(
        text: entityMap['text']['S'],
        type: entityMap['type']['S'].toLowerCase(),
        sentiment: entityMap['sentiment']['S'].toLowerCase(),
      );
    }).toList();
  }
}


  // Fetch text analysis from Lambda
  // Future<AnalysisResult> getTextAnalysis(String textInput) async {
  //   final rawData = await networkService.getTextAnalysis(textInput: textInput);

  //   // Transform raw data to AnalysisResult model
  //   return AnalysisResult.fromJson(rawData);
  // }