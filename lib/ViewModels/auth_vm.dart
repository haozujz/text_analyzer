import 'dart:async';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthError {
  userNotFound("User does not exist"), // Cognito user not found
  wrongPassword("Incorrect password"), // Wrong password
  userNotConfirmed("User is not confirmed"), // Unverified account
  sessionExpired("Session expired. Please log in again."), // Expired session
  userDeleted("User has been deleted."), // User deleted from Cognito
  notAuthorized("Not authorized"), // Unauthorized action
  networkError("No internet connection"), // Network issue
  emptyFields("Please fill in all fields"), // Empty fields
  unknown("An unknown authentication error occurred"); // Catch-all

  final String message;
  const AuthError(this.message);

  static AuthError fromException(Exception e) {
    final message = e.toString().toLowerCase();
    if (message.contains("user not found")) return AuthError.userNotFound;
    if (message.contains("incorrect username or password")) {
      return AuthError.wrongPassword;
    }
    if (message.contains("user is not confirmed")) {
      return AuthError.userNotConfirmed;
    }
    if (message.contains("session expired")) return AuthError.sessionExpired;
    if (message.contains("user has been deleted")) return AuthError.userDeleted;
    if (message.contains("not authorized")) return AuthError.notAuthorized;
    if (message.contains("network")) return AuthError.networkError;
    return AuthError.unknown;
  }
}

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>(
  (ref) => AuthViewModel(),
);

class AuthState {
  final bool isSignedIn;
  final String? error;
  final String? user;
  final String? email;

  AuthState({this.isSignedIn = false, this.error, this.user, this.email});

  AuthState copyWith({
    bool? isSignedIn,
    String? error,
    String? user,
    String? email,
  }) {
    return AuthState(
      isSignedIn: isSignedIn ?? this.isSignedIn,
      error: error,
      user: user,
      email: email,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState>
    with WidgetsBindingObserver {
  AuthViewModel() : super(AuthState()) {
    WidgetsBinding.instance.addObserver(this); // Lifecycle observer
    _checkAuthStatus();
    listenToAuthEvents(); // Start listening to auth events
  }

  StreamSubscription? _subscription;

  Future<void> _checkAuthStatus() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      final isSignedIn = session.isSignedIn;
      _updateAuthState(isSignedIn, null);
    } catch (e) {
      _updateAuthState(false, e.toString());
    }
  }

  Future<Map<String, String>> getUserEmailAndSub() async {
    try {
      final attributes = await Amplify.Auth.fetchUserAttributes();
      String? email;
      String? sub;

      for (var attr in attributes) {
        if (attr.userAttributeKey.key == 'email') {
          email = attr.value;
        } else if (attr.userAttributeKey.key == 'sub') {
          sub = attr.value;
        }
      }

      if (email != null && sub != null) {
        return {'email': email, 'sub': sub};
      } else {
        throw Exception('Email or sub not found.');
      }
    } catch (e) {
      rethrow;
    }
  }

  void listenToAuthEvents() {
    _subscription = Amplify.Hub.listen(HubChannel.Auth, (event) {
      switch (event.type) {
        case AuthHubEventType.signedIn:
          _updateAuthState(true, null);
          break;
        case AuthHubEventType.signedOut:
          _updateAuthState(false, null);
          break;
        case AuthHubEventType.sessionExpired:
          _updateAuthState(false, "Session expired. Please log in again.");
          break;
        case AuthHubEventType.userDeleted:
          _updateAuthState(false, "User has been deleted.");
          break;
      }
    });
  }

  void _updateAuthState(bool isSignedIn, String? error) async {
    if (isSignedIn) {
      try {
        Map<String, String>? userDetails = await getUserEmailAndSub();

        state = state.copyWith(
          isSignedIn: isSignedIn,
          error: error,
          user: userDetails['sub'],
          email: userDetails['email'],
        );
      } catch (e) {
        state = state.copyWith(
          isSignedIn: false,
          error: AuthError.userNotFound.message,
        );
      }
    } else {
      state = state.copyWith(isSignedIn: isSignedIn, error: error, user: null);
    }
  }

  Future<void> signIn(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      _updateAuthState(false, AuthError.emptyFields.message);
      return;
    }

    try {
      await Amplify.Auth.signIn(username: username, password: password);

      // Already handled by _subscription
      // if (result.isSignedIn) {
      //   _updateAuthState(true, null);
      // } else {
      //   _updateAuthState(false, AuthError.unknown.message);
      // }
    } catch (e) {
      final authError = AuthError.fromException(e as Exception);
      _updateAuthState(false, authError.message);
    }
  }

  Future<void> signUp(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _updateAuthState(false, AuthError.emptyFields.message);
      return;
    }

    try {
      final userAttributes = {AuthUserAttributeKey.email: email};
      final result = await Amplify.Auth.signUp(
        username: email,
        password: password,
        options: SignUpOptions(userAttributes: userAttributes),
      );
      if (result.nextStep.signUpStep == AuthSignUpStep.confirmSignUp) {
        _updateAuthState(false, "Verification code sent to email.");
      }
    } catch (e) {
      _updateAuthState(false, "Sign-up failed: ${e.toString()}");
    }
  }

  Future<void> confirmSignUp(String email, String confirmationCode) async {
    if (email.isEmpty || confirmationCode.isEmpty) {
      _updateAuthState(false, AuthError.emptyFields.message);
      return;
    }

    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: email,
        confirmationCode: confirmationCode,
      );
      if (result.nextStep.signUpStep == AuthSignUpStep.done) {
        _updateAuthState(false, "Sign-up confirmed. Please log in.");
      }
    } catch (e) {
      _updateAuthState(false, "Confirmation failed: ${e.toString()}");
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void showMessageOnly(String message) {
    state = state.copyWith(error: message);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
