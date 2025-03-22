import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageUtils {
  // A static method to ensure the image is in .jpg format
  static Future<String> ensureJpegFormat(String imagePath) async {
    final file = File(imagePath);

    // Read the image as bytes
    final bytes = await file.readAsBytes();

    // Decode the image to get its format
    img.Image? image = img.decodeImage(Uint8List.fromList(bytes));

    if (image == null) {
      throw Exception('Invalid image format');
    }

    // If the image is already a JPEG, no need to convert
    if (imagePath.toLowerCase().endsWith('.jpg') ||
        imagePath.toLowerCase().endsWith('.jpeg')) {
      // return file; // No conversion needed
      return imagePath;
    }

    // Convert the image to JPEG format
    final jpegBytes = img.encodeJpg(image);

    // Create a new file path with the .jpg extension
    final newImagePath = imagePath.replaceAll(
      RegExp(r'\.png$|\.jpeg$|\.gif$'),
      '.jpg',
    );

    final newFile = File(newImagePath);

    // Write the JPEG data to the new file
    await newFile.writeAsBytes(jpegBytes);

    // return newFile; // Return the newly created .jpg file
    return newImagePath;
  }
}
