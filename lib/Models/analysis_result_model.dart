import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';

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

  factory AnalysisResult.fromDynamoDB(Map<String, AttributeValue> data) {
    return AnalysisResult(
      user: data['user']?.s ?? '',
      id: data['id']?.s ?? '',
      text: data['text']?.s ?? '',
      language: data['language']?.s ?? '',
      sentiment: SentimentAnalysis.fromDynamoDB(data['sentiment']?.m ?? {}),
      entities:
          (data['entitySentiments']?.l ?? [])
              .map(
                (e) => EntitySentiment.fromDynamoDB(e.m ?? {}),
              ) // Safely access map
              .toList(),
      keyPhrases: (data['keyPhrases']?.l ?? []).map((e) => e.s ?? '').toList(),
      imageId: data['imageId']?.s ?? '', //data['ImageId']?.s,
      imagePath: data['imagePath']?.s ?? '', //data['ImagePath']?.s,
      createdAt:
          DateTime.tryParse(data['createdAt']?.s ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      // data['CreatedAt']?.s != null
      //     ? DateTime.parse(data['CreatedAt']?.s ?? '')
      //     : null,
    );
  }

  Map<String, AttributeValue> toDynamoDB() {
    return {
      'user': AttributeValue(s: user),
      'id': AttributeValue(s: id),
      'text': AttributeValue(s: text),
      'language': AttributeValue(s: language),
      'sentiment': AttributeValue(m: sentiment.toDynamoDB()),
      'entitySentiments': AttributeValue(
        l: entities.map((e) => AttributeValue(m: e.toDynamoDB())).toList(),
      ),
      'keyPhrases': AttributeValue(
        l: keyPhrases.map((e) => AttributeValue(s: e)).toList(),
      ),
      'imageId': AttributeValue(s: imageId),
      //imageId != null ? AttributeValue(s: imageId!) : AttributeValue(s: ''),
      'imagePath': AttributeValue(s: imagePath),
      // imagePath != null
      //     ? AttributeValue(s: imagePath!)
      //     : AttributeValue(s: ''),
      'createdAt': AttributeValue(s: createdAt.toIso8601String()),
      // createdAt != null
      //     ? AttributeValue(s: createdAt!.toIso8601String())
      //     : AttributeValue(s: ''),
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

  factory SentimentAnalysis.fromDynamoDB(
    Map<String, AttributeValue> sentiment,
  ) {
    return SentimentAnalysis(
      sentiment: sentiment['sentiment']?.s ?? '',
      positive: double.parse(sentiment['positive']?.n ?? '0.0'),
      negative: double.parse(sentiment['negative']?.n ?? '0.0'),
      neutral: double.parse(sentiment['neutral']?.n ?? '0.0'),
      mixed: double.parse(sentiment['mixed']?.n ?? '0.0'),
    );
  }

  Map<String, AttributeValue> toDynamoDB() {
    return {
      'sentiment': AttributeValue(s: sentiment),
      'positive': AttributeValue(n: positive.toString()),
      'negative': AttributeValue(n: negative.toString()),
      'neutral': AttributeValue(n: neutral.toString()),
      'mixed': AttributeValue(n: mixed.toString()),
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

  factory EntitySentiment.fromDynamoDB(Map<String, AttributeValue> entity) {
    return EntitySentiment(
      text: entity['text']?.s ?? '',
      type: entity['type']?.s ?? '',
      sentiment: entity['sentiment']?.s ?? '',
    );
  }

  Map<String, AttributeValue> toDynamoDB() {
    return {
      'text': AttributeValue(s: text),
      'type': AttributeValue(s: type),
      'sentiment': AttributeValue(s: sentiment),
    };
  }
}
