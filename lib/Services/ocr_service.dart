import 'package:nlp_flutter/Services/logger_service.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

enum OCRError {
  noImage("No image provided for text extraction"),
  imageProcessingFailed("Invalid request data"),
  unknownError("Invalid request data");

  final String message;
  const OCRError(this.message);
}

class OCRService {
  OCRService._();
  static final OCRService _instance = OCRService._();
  factory OCRService() => _instance;

  Future<String> performOCR(String imagePath) async {
    if (imagePath.isEmpty) {
      throw OCRError.noImage;
    }

    // Initialize the text recognizer
    final textRecognizer = TextRecognizer();

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await textRecognizer.processImage(inputImage);

      String extractedText = recognizedText.text;

      LoggerService().info('Extracted Text: $extractedText');
      return extractedText;
    } catch (e) {
      throw OCRError.unknownError;
    } finally {
      // Close the text recognizer to free up resources
      textRecognizer.close();
    }
  }
}
