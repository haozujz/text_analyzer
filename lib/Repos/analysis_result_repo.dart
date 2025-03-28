import '../Models/analysis_result_model.dart';
import '../Services/network_service.dart';

class AnalysisResultRepository {
  Future<void> postAnalysisResult({
    required AnalysisResult analysisResult,
  }) async {
    try {
      await NetworkService().postAnalysisResult(analysisResult);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAnalysisResult({
    required String user,
    required String id,
  }) async {
    try {
      await NetworkService().deleteAnalysisResult(user: user, id: id);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AnalysisResult>> fetchAnalysisResults(String user) async {
    try {
      var results = await NetworkService().fetchAnalysisResults(user);
      List<AnalysisResult> parsedResults = [];

      if (results.containsKey('results')) {
        var items = results['results'];

        items.forEach((el) {
          try {
            parsedResults.add(parseAnalysisResult(el));
          } catch (e) {
            rethrow;
          }
        });
      }

      return parsedResults;
    } catch (e) {
      rethrow;
    }
  }

  AnalysisResult parseAnalysisResult(Map<String, dynamic> item) {
    try {
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
          }).toList();

      final createdAt =
          item['createdAt'] != null
              ? DateTime.tryParse(item['createdAt']) ?? DateTime.now()
              : DateTime.now();

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
      rethrow;
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
}
