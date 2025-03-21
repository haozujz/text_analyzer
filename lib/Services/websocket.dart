import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'logger_service.dart';

class WebSocketService {
  WebSocketService._();
  static final WebSocketService _instance = WebSocketService._();
  factory WebSocketService() => _instance;

  WebSocketChannel? _channel;

  final StreamController<String> _messageStreamController =
      StreamController.broadcast();
  Stream<String> get messages => _messageStreamController.stream;

  // Connect to the WebSocket API
  void connect() {
    disconnect();
    // Warning: .closeCode may be null even if the connection closed if closure was via network loss
    // if (_channel != null && _channel?.closeCode == null) {
    //   LoggerService().info("Websocket connection already open.");
    //   return;
    // }

    _channel = WebSocketChannel.connect(
      Uri.parse(
        'wss://jzkpbvgmxk.execute-api.ap-northeast-1.amazonaws.com/dev/',
      ),
    );
    listenToMessages();
  }

  void listenToMessages() {
    _channel?.stream.listen(
      (message) {
        LoggerService().info("Websocket Message received: $message");
        _messageStreamController.add(message); // Add message to stream
      },
      onError: (error) {
        LoggerService().info("Websocket Error occurred: $error");
      },
      onDone: () {
        LoggerService().info("Websocket Connection closed.");
      },
    );
  }

  void sendMessage(String message) {
    _channel?.sink.add(message);
  }

  // Disconnect the WebSocket
  void disconnect() {
    _channel?.sink.close();
  }
}
