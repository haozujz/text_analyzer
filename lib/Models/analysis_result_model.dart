import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';

class AnalysisResult {
  final String id;
  final String text;
  final String language;
  final SentimentAnalysis sentiment;
  final List<EntitySentiment> entities;
  final List<String> keyPhrases;
  final String? imageId; // For AWS s3
  final String? imagePath; // For local imagePath
  final DateTime?
  createdAt; // createdAt is given with AWS Lambda at time of saving to DynamoDB

  AnalysisResult({
    required this.id,
    required this.text,
    required this.language,
    required this.sentiment,
    required this.entities,
    required this.keyPhrases,
    this.imageId,
    this.imagePath,
    this.createdAt,
  });

  factory AnalysisResult.fromDynamoDB(Map<String, AttributeValue> data) {
    return AnalysisResult(
      id: data['id']?.s ?? '',
      text: data['Text']?.s ?? '',
      language: data['Language']?.s ?? '',
      sentiment: SentimentAnalysis.fromDynamoDB(data['Sentiment']?.m ?? {}),
      entities:
          (data['EntitySentiments']?.l ?? [])
              .map(
                (e) => EntitySentiment.fromDynamoDB(e.m ?? {}),
              ) // Safely access map
              .toList(),
      keyPhrases: (data['KeyPhrases']?.l ?? []).map((e) => e.s ?? '').toList(),
      imageId: data['ImageId']?.s,
      imagePath: data['ImagePath']?.s,
      createdAt:
          data['CreatedAt']?.s != null
              ? DateTime.parse(data['CreatedAt']?.s ?? '')
              : null,
    );
  }

  Map<String, AttributeValue> toDynamoDB() {
    return {
      'id': AttributeValue(s: id),
      'Text': AttributeValue(s: text),
      'Language': AttributeValue(s: language),
      'Sentiment': AttributeValue(m: sentiment.toDynamoDB()),
      'EntitySentiments': AttributeValue(
        l: entities.map((e) => AttributeValue(m: e.toDynamoDB())).toList(),
      ),
      'KeyPhrases': AttributeValue(
        l: keyPhrases.map((e) => AttributeValue(s: e)).toList(),
      ),
      'ImageId':
          imageId != null ? AttributeValue(s: imageId!) : AttributeValue(s: ''),
      'ImagePath':
          imagePath != null
              ? AttributeValue(s: imagePath!)
              : AttributeValue(s: ''),
      'CreatedAt':
          createdAt != null
              ? AttributeValue(s: createdAt!.toIso8601String())
              : AttributeValue(s: ''),
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

  factory SentimentAnalysis.fromDynamoDB(
    Map<String, AttributeValue> sentiment,
  ) {
    return SentimentAnalysis(
      sentiment: sentiment['Sentiment']?.s ?? '',
      positive: double.parse(sentiment['Positive']?.n ?? '0.0'),
      negative: double.parse(sentiment['Negative']?.n ?? '0.0'),
      neutral: double.parse(sentiment['Neutral']?.n ?? '0.0'),
      mixed: double.parse(sentiment['Mixed']?.n ?? '0.0'),
    );
  }

  Map<String, AttributeValue> toDynamoDB() {
    return {
      'Sentiment': AttributeValue(s: sentiment),
      'Positive': AttributeValue(n: positive.toString()),
      'Negative': AttributeValue(n: negative.toString()),
      'Neutral': AttributeValue(n: neutral.toString()),
      'Mixed': AttributeValue(n: mixed.toString()),
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

  factory EntitySentiment.fromDynamoDB(Map<String, AttributeValue> entity) {
    return EntitySentiment(
      text: entity['Text']?.s ?? '',
      type: entity['Type']?.s ?? '',
      sentiment: entity['Sentiment']?.s ?? '',
    );
  }

  Map<String, AttributeValue> toDynamoDB() {
    return {
      'Text': AttributeValue(s: text),
      'Type': AttributeValue(s: type),
      'Sentiment': AttributeValue(s: type),
    };
  }
}
