import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Models/federated_user.dart';

class SecureStorageService {
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _userKey = 'federated_user';

  Future<void> saveUser(FederatedUser user) async {
    await _storage.write(key: _userKey, value: user.toJsonString());
  }

  Future<FederatedUser?> getUser() async {
    final jsonString = await _storage.read(key: _userKey);
    if (jsonString == null) return null;
    return FederatedUser.fromJsonString(jsonString);
  }

  Future<void> clearUser() async {
    await _storage.delete(key: _userKey);
  }

  Future<bool> isIdTokenExpired() async {
    final user = await getUser();
    if (user == null) return true;
    return DateTime.now().isAfter(user.idTokenExpiry);
  }
}
