import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class LoggerService {
  // Private constructor
  LoggerService._();

  // Static instance
  static final LoggerService _instance = LoggerService._();

  // Factory constructor to return the same instance
  factory LoggerService() => _instance;

  // Logger instance with custom configuration
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 5,
      lineLength: 120,
      colors: true,
    ),
  );

  // Log methods
  void debug(String message) {
    _logger.d(message);
  }

  void info(String message) {
    _logger.i(message);
  }

  void warning(String message) {
    _logger.w(message);
  }

  void error(String message) {
    _logger.e(message);
  }

  // Replacing 'wtf' with 'error' for severe failures
  void severeFailure(String message) {
    _logger.e("WTF: $message");
  }

  void prettyPrint(String text, {int chunkSize = 800}) {
    final pattern = RegExp('.{1,$chunkSize}'); // break into 800-char chunks
    for (final match in pattern.allMatches(text)) {
      debugPrint(match.group(0)); // debugPrint handles long strings better
    }
  }
}
