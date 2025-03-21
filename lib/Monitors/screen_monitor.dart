import 'package:screen_state/screen_state.dart';
import '../Services/logger_service.dart';
import '../Services/websocket.dart';

class ScreenMonitor {
  ScreenMonitor._();
  static final ScreenMonitor _instance = ScreenMonitor._();
  factory ScreenMonitor() => _instance;

  late Screen _screen;

  void startListening() {
    _screen = Screen();
    _screen.screenStateStream.listen((event) {
      if (event == ScreenStateEvent.SCREEN_ON) {
        LoggerService().info("Screen turned on. Reconnecting WebSocket...");
        WebSocketService().connect();
      }
    });
  }
}
