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



