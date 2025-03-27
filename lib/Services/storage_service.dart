import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:nlp_flutter/Services/logger_service.dart';

class _CachedUrl {
  final String url;
  final DateTime timestamp;

  _CachedUrl(this.url, this.timestamp);

  bool isExpired(Duration ttl) {
    return DateTime.now().difference(timestamp) > ttl;
  }
}

class StorageService {
  StorageService._();
  static final StorageService _instance = StorageService._();
  factory StorageService() => _instance;

  static final _urlCache = <String, _CachedUrl>{};
  final ttl = const Duration(minutes: 15);

  Future<void> uploadFile({
    required String imagePath,
    required String imageId,
    required String identityId,
  }) async {
    try {
      final result =
          await Amplify.Storage.uploadFile(
            localFile: AWSFile.fromPath(imagePath),
            path: StoragePath.fromString(
              'photo-submissions/$identityId/$imageId.jpg',
            ),
          ).result;
      LoggerService().info('S3 Uploaded file: ${result.uploadedItem.path}');
    } on StorageException catch (e) {
      LoggerService().error('S3 error: $e.message');
      rethrow;
    }
  }

  Future<String> getUrl({
    required String imageId,
    required String identityId,
  }) async {
    final key = '$identityId/$imageId.jpg';

    // Cache
    final cached = _urlCache[key];
    if (cached != null && !cached.isExpired(ttl)) {
      return cached.url;
    }

    try {
      final exists = await isImageAvailable(
        imageId: imageId,
        identityId: identityId,
      );

      if (!exists) {
        throw Exception("Image does not exist in S3");
      }

      final result =
          await Amplify.Storage.getUrl(
            path: StoragePath.fromString(
              'photo-submissions/$identityId/$imageId.jpg',
            ),
          ).result;

      final imageUrl = result.url.toString();
      LoggerService().info('S3 Image URL: $imageUrl');
      // Cache
      _urlCache[key] = _CachedUrl(imageUrl, DateTime.now());
      return imageUrl;
    } on StorageException catch (e) {
      LoggerService().error('S3 error: $e.message');
      rethrow;
    }
  }

  Future<bool> isImageAvailable({
    required String imageId,
    required String identityId,
  }) async {
    try {
      await Amplify.Storage.getProperties(
        path: StoragePath.fromString(
          'photo-submissions/$identityId/$imageId.jpg',
        ),
      ).result;

      return true;
    } on StorageException catch (e) {
      if (e.message.contains('NoSuchKey')) {
        LoggerService().error('Image not found: $imageId.jpg');
      } else {
        LoggerService().error('Error checking image: ${e.message}');
      }
      return false;
    }
  }
}
