import 'dart:async';
import 'dart:io';
import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
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

  final apiKey = '58FjYJsljJ8OXY3wolrT61DDN1B17ZEH2I6op1A9';

  Future<Map<String, dynamic>> fetchTextAnalysis({
    required String textInput,
  }) async {
    try {
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

  Future<Map<String, dynamic>> postAnalysisResult() async {
    try {
      final analysisResult = AnalysisResult(
        user: '123user',
        id: '123id',
        text: 'test input text',
        language: 'en',
        sentiment: SentimentAnalysis(
          sentiment: 'POSITIVE',
          positive: 0.9,
          negative: 0.05,
          neutral: 0.05,
          mixed: 0.0,
        ),
        entities: [
          EntitySentiment(
            text: 'entity1',
            type: 'PERSON',
            sentiment: 'POSITIVE',
          ),
        ],
        keyPhrases: ['keyphrase1', 'keyphrase2'],
        imageId: 'img123',
        imagePath: '',
        createdAt: DateTime.parse('2025-03-18T12:34:56Z'),
      );

      // final dynamoDBMap = analysisResult.toDynamoDB();

      // print('Dyn convert: $dynamoDBMap'); //
      // final j = json.encode(dynamoDBMap); //
      // print('Dyn encode: $j'); //

      // Convert DynamoDB map to a plain JSON structure
      // Map<String, dynamic> toPlainJson(
      //   Map<String, AttributeValue> dynamoDBMap,
      // ) {
      //   return dynamoDBMap.map((key, value) {
      //     if (value.s != null) return MapEntry(key, value.s);
      //     if (value.n != null) return MapEntry(key, double.tryParse(value.n!));
      //     if (value.m != null) return MapEntry(key, toPlainJson(value.m!));
      //     if (value.l != null) {
      //       return MapEntry(
      //         key,
      //         value.l!.map((item) => toPlainJson(item.m ?? {})).toList(),
      //       );
      //     }
      //     return MapEntry(key, null);
      //   });
      // }

      //final jsonString = json.encode(toPlainJson(dynamoDBMap));

      //print('Dyn json: $jsonString');

      final response = await http.post(
        Uri.parse(
          'https://0c1qfilb2f.execute-api.ap-northeast-1.amazonaws.com/dev/results_db',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(analysisResult.toJson()),
        //body:
        //"{\"user\": \"123user\", \"id\": \"123id\", \"text\": \"This is a test text\", \"language\": \"en\", \"sentiment\": {\"sentiment\": \"POSITIVE\", \"positive\": 0.9, \"negative\": 0.05, \"neutral\": 0.05, \"mixed\": 0.0}, \"entities\": [{\"text\": \"entity1\", \"type\": \"PERSON\", \"sentiment\": \"POSITIVE\"}], \"keyPhrases\": [\"keyphrase1\", \"keyphrase2\"], \"imageId\": \"img123\", \"imagePath\": \"/images/img123.jpg\", \"createdAt\": \"2025-03-18T12:34:56Z\"}",
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










// import json
// import boto3
// from botocore.exceptions import ClientError

// dynamodb = boto3.resource('dynamodb')
// table = dynamodb.Table('AnalysisResults')

// def lambda_handler(event, context):
//     try:
//         # Parse input
//         user = event['user']
//         id = event['id']
//         text = event['text']
//         language = event['language']
//         sentiment = event['sentiment']
//         entities = event['entities']
//         keyPhrases = event['keyPhrases']
//         imageId = event.get('imageId', None)
//         imagePath = event.get('imagePath', None)
//         createdAt = event['createdAt']

//         # Create item
//         response = table.put_item(
//             Item={
//                 'user': user,
//                 'id': id,
//                 'Text': text,
//                 'Language': language,
//                 'Sentiment': sentiment,
//                 'EntitySentiments': entities,
//                 'KeyPhrases': keyPhrases,
//                 'ImageId': imageId,
//                 'ImagePath': imagePath,
//                 'CreatedAt': createdAt
//             }
//         )
//         return {
//             'statusCode': 200,
//             'body': json.dumps('Item created successfully')
//         }

//     except ClientError as e:
//         print(f"Error creating item: {e.response['Error']['Message']}")
//         return {
//             'statusCode': 500,
//             'body': json.dumps(f"Error creating item: {e.response['Error']['Message']}")
//         }





// import json
// import boto3
// from botocore.exceptions import ClientError

// dynamodb = boto3.resource('dynamodb')
// table = dynamodb.Table('AnalysisResults')

// def lambda_handler(event, context):
//     try:
//         # Extract user and id from the event
//         user = event['user']
//         id = event['id']

//         # Delete item
//         response = table.delete_item(
//             Key={
//                 'user': user,
//                 'id': id
//             }
//         )
        
//         if 'Attributes' in response:
//             return {
//                 'statusCode': 200,
//                 'body': json.dumps('Item deleted successfully')
//             }
//         else:
//             return {
//                 'statusCode': 404,
//                 'body': json.dumps('Item not found')
//             }
        
//     except ClientError as e:
//         print(f"Error deleting item: {e.response['Error']['Message']}")
//         return {
//             'statusCode': 500,
//             'body': json.dumps(f"Error deleting item: {e.response['Error']['Message']}")
//         }






// import json
// import boto3
// from botocore.exceptions import ClientError

// dynamodb = boto3.resource('dynamodb')
// table = dynamodb.Table('AnalysisResults')

// def lambda_handler(event, context):
//     try:
//         # Extract user from the event
//         user = event['user']

//         # Query DynamoDB by user (partition key)
//         response = table.query(
//             KeyConditionExpression=boto3.dynamodb.conditions.Key('user').eq(user)
//         )
        
//         items = response.get('Items', [])
        
//         if items:
//             return {
//                 'statusCode': 200,
//                 'body': json.dumps(items)
//             }
//         else:
//             return {
//                 'statusCode': 404,
//                 'body': json.dumps('No items found for this user')
//             }
        
//     except ClientError as e:
//         print(f"Error querying items: {e.response['Error']['Message']}")
//         return {
//             'statusCode': 500,
//             'body': json.dumps(f"Error querying items: {e.response['Error']['Message']}")
//         }



