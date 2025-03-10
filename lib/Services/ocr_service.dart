import 'package:nlp_flutter/Services/logger_service.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

// import 'dart:io';
// import 'dart:typed_data';
// import 'package:image/image.dart' as img;
// import 'package:path_provider/path_provider.dart';

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
      //LoggerService().info('No image provided for OCR.');
      throw OCRError.noImage;
    }

    // Initialize the text recognizer
    final textRecognizer = TextRecognizer();

    try {
      // Load the image as a File
      //final inputImage = InputImage.fromFile(File(imagePath));
      final inputImage = InputImage.fromFilePath(imagePath);
      // Process the image
      final recognizedText = await textRecognizer.processImage(inputImage);

      // Retrieve the text result
      String extractedText = recognizedText.text;

      // Handle the extracted text as needed
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

  // Future<String> preprocessImage(String imagePath) async {
  //   // Read the image
  //   final File imageFile = File(imagePath);
  //   final Uint8List imageBytes = await imageFile.readAsBytes();

  //   // Decode image
  //   img.Image? image = img.decodeImage(imageBytes);
  //   if (image == null) {
  //     throw Exception("Failed to decode image");
  //   }

  //   // Convert to grayscale
  //   image = img.grayscale(image);

  //   // Increase contrast and adjust brightness
  //   image = img.adjustColor(image, contrast: 1.5, brightness: 10);

  //   // Resize for better OCR accuracy (adjust size as needed)
  //   //image = img.copyResize(image, width: 1024);

  //   // Save the processed image
  //   final Directory tempDir = await getTemporaryDirectory();
  //   final String processedImagePath = '${tempDir.path}/processed_image.jpg';
  //   final File processedImageFile = File(processedImagePath);
  //   await processedImageFile.writeAsBytes(img.encodeJpg(image));

  //   return processedImagePath;
  // }
