import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;

import '../../Services/logger_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

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
          'scope': 'aws.cognito.signin.user.admin email openid phone profile',
          'redirect_uri': _redirectUri,
        },
      );

      final result = await FlutterWebAuth2.authenticate(
        url: uri.toString(),
        callbackUrlScheme: 'myapp',
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

      LoggerService().info('Access token: ${tokenData['access_token']}');
      LoggerService().info('ID token: ${tokenData['id_token']}');
      LoggerService().info('Refresh token: ${tokenData['refresh_token']}');

      final session = await Amplify.Auth.fetchAuthSession();
      LoggerService().info('✅ Signed in: ${session.isSignedIn}');
      return tokenData;
    } catch (e) {
      throw Exception('Hosted UI sign-in failed: $e');
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
}
