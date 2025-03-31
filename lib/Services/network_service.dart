import 'dart:async';
import 'dart:io';
//import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Models/analysis_result_model.dart';

enum NetworkError {
  badRequest("Invalid request data"), // 400
  unauthorized("Invalid API key"), // 401
  forbidden("Access denied"), // 403
  notFound("API endpoint not found"), // 404
  serverError("AWS server error"), // 500+
  timeout("Request timed out"), // Timeout or API Gateway failure
  noInternet("No internet connection"), // No network connection
  unknown("An unknown error occurred"); // Catch-all

  final String message;
  const NetworkError(this.message);
}

class NetworkService {
  NetworkService._();
  static final NetworkService _instance = NetworkService._();
  factory NetworkService() => _instance;

  final baseUrl =
      'https://0c1qfilb2f.execute-api.ap-northeast-1.amazonaws.com/dev/';

  final apiKey = dotenv.env['API_KEY'] ?? '';

  Future<Map<String, dynamic>> fetchTextAnalysis({
    required String textInput,
  }) async {
    try {
      if (apiKey == '') {
        throw NetworkError.unauthorized;
      }

      final response = await http.post(
        Uri.parse('${baseUrl}process_text'),
        headers: {'x-api-key': apiKey, 'Content-Type': 'application/json'},
        body: json.encode({'text': textInput}),
      );

      switch (response.statusCode) {
        case 200:
          return json.decode(response.body);
        case 400:
          throw NetworkError.badRequest;
        case 401:
          throw NetworkError.unauthorized;
        case 403:
          throw NetworkError.forbidden;
        case 404:
          throw NetworkError.notFound;
        case 500:
        case 502:
        case 503:
          throw NetworkError.serverError;
        default:
          throw NetworkError.unknown;
      }
    } on SocketException {
      throw NetworkError.noInternet;
    } on TimeoutException {
      throw NetworkError.timeout;
    } on NetworkError {
      rethrow;
    } catch (e) {
      throw NetworkError.unknown;
    }
  }

  Future<Map<String, dynamic>> postAnalysisResult(
    AnalysisResult analysisResult,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}results_db'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(analysisResult.toJson()),
      );

      switch (response.statusCode) {
        case 200:
          return json.decode(response.body);
        case 400:
          throw NetworkError.badRequest;
        case 401:
          throw NetworkError.unauthorized;
        case 403:
          throw NetworkError.forbidden;
        case 404:
          throw NetworkError.notFound;
        case 500:
        case 502:
        case 503:
          throw NetworkError.serverError;
        default:
          throw NetworkError.unknown;
      }
    } on SocketException {
      throw NetworkError.noInternet;
    } on TimeoutException {
      throw NetworkError.timeout;
    } on NetworkError {
      rethrow;
    } catch (e) {
      throw NetworkError.unknown;
    }
  }

  Future<Map<String, dynamic>> deleteAnalysisResult({
    required String user,
    required String id,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('${baseUrl}results_db'),
        headers: {
          'Content-Type': 'application/json',
          //'x-api-key': apiKey,
        },
        body: json.encode({'user': user, 'id': id}),
      );

      switch (response.statusCode) {
        case 200:
          return json.decode(response.body);
        case 400:
          throw NetworkError.badRequest;
        case 401:
          throw NetworkError.unauthorized;
        case 403:
          throw NetworkError.forbidden;
        case 404:
          throw NetworkError.notFound;
        case 500:
        case 502:
        case 503:
          throw NetworkError.serverError;
        default:
          throw NetworkError.unknown;
      }
    } on SocketException {
      throw NetworkError.noInternet;
    } on TimeoutException {
      throw NetworkError.timeout;
    } on NetworkError {
      rethrow;
    } catch (e) {
      throw NetworkError.unknown;
    }
  }

  Future<Map<String, dynamic>> fetchAnalysisResults(String user) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}results_db?user=$user'),
        headers: {'Content-Type': 'application/json'},
      );

      switch (response.statusCode) {
        case 200:
          return json.decode(response.body);
        case 400:
          throw NetworkError.badRequest;
        case 401:
          throw NetworkError.unauthorized;
        case 403:
          throw NetworkError.forbidden;
        case 404:
          throw NetworkError.notFound;
        case 500:
        case 502:
        case 503:
          throw NetworkError.serverError;
        default:
          throw NetworkError.unknown;
      }
    } on SocketException {
      throw NetworkError.noInternet;
    } on TimeoutException {
      throw NetworkError.timeout;
    } on NetworkError {
      rethrow;
    } catch (e) {
      throw NetworkError.unknown;
    }
  }
}




//"{\"user\": \"123user\", \"id\": \"123id\", \"text\": \"This is a test text\", \"language\": \"en\", \"sentiment\": {\"sentiment\": \"POSITIVE\", \"positive\": 0.9, \"negative\": 0.05, \"neutral\": 0.05, \"mixed\": 0.0}, \"entities\": [{\"text\": \"entity1\", \"type\": \"PERSON\", \"sentiment\": \"POSITIVE\"}], \"keyPhrases\": [\"keyphrase1\", \"keyphrase2\"], \"imageId\": \"img123\", \"imagePath\": \"/images/img123.jpg\", \"createdAt\": \"2025-03-18T12:34:56Z\"}",


     // final analysisResult = AnalysisResult(
      //   user: '123user',
      //   id: '123id',
      //   text: 'test input text',
      //   language: 'en',
      //   sentiment: SentimentAnalysis(
      //     sentiment: 'POSITIVE',
      //     positive: 0.9,
      //     negative: 0.05,
      //     neutral: 0.05,
      //     mixed: 0.0,
      //   ),
      //   entities: [
      //     EntitySentiment(
      //       text: 'entity1',
      //       type: 'PERSON',
      //       sentiment: 'POSITIVE',
      //     ),
      //   ],
      //   keyPhrases: ['keyphrase1', 'keyphrase2'],
      //   imageId: 'img123',
      //   imagePath: '',
      //   createdAt: DateTime.parse('2025-03-18T12:34:56Z'),
      // );

//entities
//[ { "M" : { "type" : { "S" : "software" }, "sentiment" : { "S" : "neutral" }, "text" : { "S" : "GarchompeX" } } }, { "M" : { "type" : { "S" : "other" }, "sentiment" : { "S" : "neutral" }, "text" : { "S" : "Evohres" } } }, { "M" : { "type" : { "S" : "organization" }, "sentiment" : { "S" : "neutral" }, "text" : { "S" : "Gabite  Linear" } } }, { "M" : { "type" : { "S" : "quantity" }, "sentiment" : { "S" : "neutral" }, "text" : { "S" : "50" } } }, { "M" : { "type" : { "S" : "quantity" }, "sentiment" : { "S" : "neutral" }, "text" : { "S" : "1" } } }, { "M" : { "type" : { "S" : "person" }, "sentiment" : { "S" : "neutral" }, "text" : { "S" : "your" } } }, { "M" : { "type" : { "S" : "person" }, "sentiment" : { "S" : "neutral" }, "text" : { "S" : "opponent" } } }, { "M" : { "type" : { "S" : "person" }, "sentiment" : { "S" : "neutral" }, "text" : { "S" : "opponent" } } }, { "M" : { "type" : { "S" : "other" }, "sentiment" : { "S" : "neutral" }, "text" : { "S" : "Pokémon" } } }, { "M" : { "type" : { "S" : "other" }, "sentiment" : { "S" : "neutral" }, "text" : { "S" : "Pokémon" } } }, { "M" : { "type" : { "S" : "person" }, "sentiment" : { "S" : "neutral" }, "text" : { "S" : "totiycto" } } }, { "M" : { "type" : { "S" : "organization" }, "sentiment" : { "S" : "neutral" }, "text" : { "S" : "Dragon" } } }, { "M" : { "type" : { "S" : "quantity" }, "sentiment" : { "S" : "neutral" }, "text" : { "S" : "+20" } } }, { "M" : { "type" : { "S" : "quantity" }, "sentiment" : { "S" : "neutral" }, "text" : { "S" : "170" } } }, { "M" : { "type" : { "S" : "person" }, "sentiment" : { "S" : "neutral" }, "text" : { "S" : "your" } } }, { "M" : { "type" : { "S" : "person" }, "sentiment" : { "S" : "neutral" }, "text" : { "S" : "your" } } }, { "M" : { "type" : { "S" : "quantity" }, "sentiment" : { "S" : "neutral" }, "text" : { "S" : "2" } } }, { "M" : { "type" : { "S" : "quantity" }, "sentiment" : { "S" : "neutral" }, "text" : { "S" : "100" } } } ]
//sentiment
//{ "sentiment" : { "S" : "neutral" }, "neutral" : { "N" : "98.11716079711914" }, "negative" : { "N" : "1.2047290802001953" }, "mixed" : { "N" : "0.010068455594591796" }, "positive" : { "N" : "0.6680459249764681" } }

