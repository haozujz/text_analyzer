import 'package:connectivity_plus/connectivity_plus.dart';
import '../Services/logger_service.dart';
import '../Services/websocket.dart';

class NetworkMonitor {
  NetworkMonitor._();
  static final NetworkMonitor _instance = NetworkMonitor._();
  factory NetworkMonitor() => _instance;

  void startListening() {
    Connectivity().onConnectivityChanged.listen((status) {
      if (status != ConnectivityResult.none) {
        LoggerService().info("Network reconnected. Reconnecting WebSocket...");
        WebSocketService()
            .connect(); // Lazy initialization of WebSocketService when network is available
      }
    });
  }
}
