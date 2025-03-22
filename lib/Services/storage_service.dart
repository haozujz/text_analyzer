import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:nlp_flutter/Services/logger_service.dart';

class StorageService {
  StorageService._();
  static final StorageService _instance = StorageService._();
  factory StorageService() => _instance;

  Future<void> uploadFile({
    required String imagePath,
    required String imageId,
    required String userId,
  }) async {
    try {
      final result =
          await Amplify.Storage.uploadFile(
            localFile: AWSFile.fromPath(imagePath),
            path: StoragePath.fromString(
              'photo-submissions/$userId/$imageId.jpg',
            ),
          ).result;
      LoggerService().info('S3 Uploaded file: ${result.uploadedItem.path}');
    } on StorageException catch (e) {
      LoggerService().error('S3 error: $e.message');
      rethrow;
    }
  }

  Future<String> getDownloadUrl({required String imageId}) async {
    try {
      final result =
          await Amplify.Storage.getUrl(
            path: StoragePath.fromString('image-submissions/$imageId.jpg'),
          ).result;

      // Get the URL and use it to display the image
      final imageUrl = result.url.toString();
      LoggerService().info('S3 Image URL: $imageUrl');
      return imageUrl;

      // You can now use this URL to display the image
      // Example with Image.network:
      // Image.network(imageUrl);
    } on StorageException catch (e) {
      LoggerService().error('S3 error: $e.message');
      rethrow;
    }
  }
}

// import 'dart:io' show File;

// import 'package:amplify_flutter/amplify_flutter.dart';
// import 'package:aws_common/vm.dart';

// Future<void> uploadFile(File file) async {
//   try {
//     final result = await Amplify.Storage.uploadFile(
//       localFile: AWSFilePlatform.fromFile(file),
//       path: const StoragePath.fromString('public/file.png'),
//     ).result;
//     safePrint('Uploaded file: ${result.uploadedItem.path}');
//   } on StorageException catch (e) {
//     safePrint(e.message);
//   }
// }
