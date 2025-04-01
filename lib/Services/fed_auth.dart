import 'dart:convert';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

import '../Models/federated_user.dart';
import 'logger_service.dart';
import 'network_service.dart';
import 'secure_storage_service.dart';

class FedAuthService {
  static final FedAuthService _instance = FedAuthService._internal();

  factory FedAuthService() {
    return _instance;
  }

  FedAuthService._internal();

  final _clientId = '5ogh6lid1onu5vri5vs5s8de9u';
  final _redirectUri = 'myapp://callback/';
  final _authDomain =
      'https://fb6b69885de21932c1f2.auth.ap-southeast-2.amazoncognito.com';

  Future<Map<String, dynamic>> signInWithHostedUI() async {
    try {
      final uri = Uri.https(
        'fb6b69885de21932c1f2.auth.ap-southeast-2.amazoncognito.com',
        '/login',
        {
          'client_id': _clientId,
          'response_type': 'code',
          'scope': 'aws.cognito.signin.user.admin email openid profile',
          'redirect_uri': _redirectUri,
        },
      );

      final result = await FlutterWebAuth2.authenticate(
        url: uri.toString(),
        callbackUrlScheme: 'myapp',
        options: const FlutterWebAuth2Options(
          preferEphemeral: true, // iOS/macOS: incognito session
          intentFlags: ephemeralIntentFlags, // Android: incognito-like flags
          useWebview: true, // For Linux/Windows, optional
        ),
      );

      LoggerService().info('✅ Redirected back into app: $result');

      final callbackUri = Uri.parse(result);
      LoggerService().info(
        "Callback URI query parameters: ${callbackUri.queryParameters}",
      );

      final code = callbackUri.queryParameters['code'];

      if (code == null) {
        throw Exception('Authorization code not found');
      }

      LoggerService().info('✅ Received authorization code: $code');

      var tokenData = await _fetchToken(code);

      //LoggerService().info('✅ TokenData: $tokenData');
      //LoggerService().info('Access token: ${tokenData['access_token']}');
      //LoggerService().info('ID token: ${tokenData['id_token']}');
      //LoggerService().info('Refresh token: ${tokenData['refresh_token']}');

      final cognitoPlugin = Amplify.Auth.getPlugin(
        AmplifyAuthCognito.pluginKey,
      );

      final session = await cognitoPlugin.federateToIdentityPool(
        token: tokenData['id_token'],
        provider: AuthProvider.custom(
          "cognito-idp.ap-southeast-2.amazonaws.com/ap-southeast-2_G4lXj0Yfe",
        ),
      );

      LoggerService().prettyPrint(
        'Federeted login session: ${session.toJson()}',
      );

      final Map<String, dynamic> decodedToken = JwtDecoder.decode(
        tokenData['id_token'],
      );
      final sub = decodedToken['sub'];
      final email = decodedToken['email'];
      // final identityId = session.identityId;
      // LoggerService().info("✅ FedUser sub: $sub");
      // LoggerService().info("✅ FedUser email: $email");
      // LoggerService().info("✅ FedUser identityId: $identityId");

      return {
        ...tokenData,
        'identityId': session.identityId,
        'sub': sub,
        'email': email,
      };
    } catch (e) {
      LoggerService().error(
        ' User cancelled login or WebAuth error, Hosted UI sign-in failed: $e',
      );
      throw NetworkError.unknown;
    }
  }

  Future<Map<String, dynamic>> _fetchToken(String code) async {
    final response = await http.post(
      Uri.parse('$_authDomain/oauth2/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'client_id': _clientId,
        'code': code,
        'redirect_uri': _redirectUri,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Token exchange failed: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<bool> refreshSessionIfNeeded() async {
    final user = await SecureStorageService().getUser();
    if (user == null) return false;

    final isExpired = DateTime.now().isAfter(user.idTokenExpiry);
    if (!isExpired) return true; // session still valid

    try {
      final response = await http.post(
        Uri.parse('$_authDomain/oauth2/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'refresh_token',
          'client_id': _clientId,
          'refresh_token': user.refreshToken,
        },
      );

      if (response.statusCode != 200) {
        LoggerService().error("🔁 Refresh token failed: ${response.body}");
        return false;
      }

      final tokenData = jsonDecode(response.body);
      final decodedId = JwtDecoder.decode(tokenData['id_token']);
      final exp = decodedId['exp'];
      final expiry = DateTime.fromMillisecondsSinceEpoch(
        int.parse(exp.toString()) * 1000,
      );

      final refreshedUser = FederatedUser(
        sub: user.sub,
        email: user.email,
        accessToken: tokenData['access_token'],
        idToken: tokenData['id_token'],
        refreshToken: user.refreshToken, // Reuse the same refresh token
        idTokenExpiry: expiry,
      );

      await SecureStorageService().saveUser(refreshedUser);
      LoggerService().info("🔁 Token refreshed successfully.");
      return true;
    } catch (e) {
      LoggerService().error("🔁 Silent re-auth failed: $e");
      return false;
    }
  }
}

      // final refreshedUser = FederatedUser(
      //   sub: user.sub,
      //   email: user.email,
      //   accessToken: tokenData['access_token'],
      //   idToken: tokenData['id_token'],
      //   refreshToken: user.refreshToken, // Reuse the same refresh token
      //   idTokenExpiry: expiry,
      // );