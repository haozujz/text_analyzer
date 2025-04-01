import 'dart:convert';

class FederatedUser {
  final String sub;
  final String email;
  final String accessToken;
  final String idToken;
  final String refreshToken;
  final DateTime idTokenExpiry;

  FederatedUser({
    required this.sub,
    required this.email,
    required this.accessToken,
    required this.idToken,
    required this.refreshToken,
    required this.idTokenExpiry,
  });

  factory FederatedUser.fromJson(Map<String, dynamic> json) => FederatedUser(
    sub: json['sub'],
    email: json['email'],
    accessToken: json['accessToken'],
    idToken: json['idToken'],
    refreshToken: json['refreshToken'],
    idTokenExpiry: DateTime.parse(json['idTokenExpiry']),
  );

  Map<String, dynamic> toJson() => {
    'sub': sub,
    'email': email,
    'accessToken': accessToken,
    'idToken': idToken,
    'refreshToken': refreshToken,
    'idTokenExpiry': idTokenExpiry.toIso8601String(),
  };

  String toJsonString() => jsonEncode(toJson());

  factory FederatedUser.fromJsonString(String jsonStr) =>
      FederatedUser.fromJson(jsonDecode(jsonStr));
}
