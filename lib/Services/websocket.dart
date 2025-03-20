import 'package:web_socket_channel/web_socket_channel.dart';
import 'logger_service.dart';

class WebSocketService {
  WebSocketService._();
  static final WebSocketService _instance = WebSocketService._();
  factory WebSocketService() => _instance;

  // final _channel = WebSocketChannel.connect(
  //   Uri.parse('wss://jzkpbvgmxk.execute-api.ap-northeast-1.amazonaws.com/dev/'),
  // );

  late WebSocketChannel _channel;

  // Connect to the WebSocket API
  void connect() {
    _channel = WebSocketChannel.connect(
      Uri.parse(
        'wss://jzkpbvgmxk.execute-api.ap-northeast-1.amazonaws.com/dev/',
      ),
    );
    listenToMessages();
  }

  void listenToMessages() {
    _channel.stream.listen(
      (message) {
        LoggerService().info("Message received: $message");
      },
      onError: (error) {
        LoggerService().info("Error occurred: $error");
      },
      onDone: () {
        LoggerService().info("Connection closed.");
      },
    );
  }

  void sendMessage(String message) {
    _channel.sink.add(message);
  }

  // Disconnect the WebSocket
  void disconnect() {
    _channel.sink.close();
  }
}


//   RealTimeDataFetcher._();
//   static final RealTimeDataFetcher _instance = RealTimeDataFetcher._();
//   factory RealTimeDataFetcher() => _instance;

// Create the WebSocket channel to connect
// final channel = WebSocketChannel.connect(
//   Uri.parse('wss://your-websocket-url/dev'),
// );

// // Listen to the WebSocket stream for messages
// channel.stream.listen((message) {
//   print("Message received: $message");
// });

// // Send a message to the WebSocket server (if needed)
// channel.sink.add('Hello WebSocket!');





// import 'package:web_socket_channel/io.dart';
// import 'dart:convert';

// final String userId = "123user";  // Replace with actual user ID
// final channel = IOWebSocketChannel.connect(
//   'wss://your-websocket-api-id.execute-api.region.amazonaws.com/production'
// );

// // Send user ID when connecting
// channel.sink.add(jsonEncode({"action": "connect", "userId": userId}));


// channel.stream.listen((message) {
//   final data = jsonDecode(message);
  
//   if (data['type'] == 'INSERT' || data['type'] == 'MODIFY') {
//     updateUIWithNewObject(data['data']);  // Custom function to update UI
//   } else if (data['type'] == 'REMOVE') {
//     removeObjectFromUI(data['data']['id']);  // Handle deletion
//   }
// });

// void updateUIWithNewObject(Map<String, dynamic> object) {
//   print("Updated Object: ${object['text']}");
//   // Update UI state with new data
// }


