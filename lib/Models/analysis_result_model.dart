class AnalysisResult {
  final String user;
  final String id;
  final String text;
  final String language;
  final SentimentAnalysis sentiment;
  final List<EntitySentiment> entities;
  final List<String> keyPhrases;
  final String imageId; // For AWS s3
  final String imagePath; // For local imagePath
  final DateTime createdAt;

  AnalysisResult({
    required this.user,
    required this.id,
    required this.text,
    required this.language,
    required this.sentiment,
    required this.entities,
    required this.keyPhrases,
    required this.imageId,
    required this.imagePath,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'id': id,
      'text': text,
      'language': language,
      'sentiment': sentiment.toJson(),
      'entities': entities.map((e) => e.toJson()).toList(),
      'keyPhrases': keyPhrases,
      'imageId': imageId,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class SentimentAnalysis {
  final String sentiment;
  final double positive;
  final double negative;
  final double neutral;
  final double mixed;

  SentimentAnalysis({
    required this.sentiment,
    required this.positive,
    required this.negative,
    required this.neutral,
    required this.mixed,
  });

  Map<String, dynamic> toJson() {
    return {
      'sentiment': sentiment,
      'positive': positive,
      'negative': negative,
      'neutral': neutral,
      'mixed': mixed,
    };
  }
}

class EntitySentiment {
  final String text;
  final String type;
  final String sentiment;

  EntitySentiment({
    required this.text,
    required this.type,
    required this.sentiment,
  });

  Map<String, dynamic> toJson() {
    return {'text': text, 'type': type, 'sentiment': sentiment};
  }
}
