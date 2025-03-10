import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      'https://0c1qfilb2f.execute-api.ap-northeast-1.amazonaws.com/dev/process_text';

  Future<Map<String, dynamic>> fetchTextAnalysis({
    required String textInput,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'x-api-key': '58FjYJsljJ8OXY3wolrT61DDN1B17ZEH2I6op1A9',
          'Content-Type': 'application/json',
        },
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
}
