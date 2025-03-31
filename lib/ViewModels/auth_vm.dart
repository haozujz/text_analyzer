import 'dart:async';
import 'dart:math';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:nlp_flutter/Models/federated_user.dart';
import 'package:nlp_flutter/Services/fed_auth.dart';
import 'package:nlp_flutter/Services/logger_service.dart';
import 'package:nlp_flutter/Services/secure_storage_service.dart';

// import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

enum AuthError {
  userNotFound("User does not exist"), // Cognito user not found
  wrongPassword("Incorrect password"), // Wrong password
  userNotConfirmed("User is not confirmed"), // Unverified account
  identityIdMissing("User's identitiy id is missing"), // Unverified account
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
  final String? identityId;

  AuthState({
    this.isSignedIn = false,
    this.error,
    this.user,
    this.email,
    this.identityId,
  });

  AuthState copyWith({
    bool? isSignedIn,
    String? error,
    String? user,
    String? email,
    String? identityId,
  }) {
    return AuthState(
      isSignedIn: isSignedIn ?? this.isSignedIn,
      error: error,
      user: user,
      email: email,
      identityId: identityId,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState>
    with WidgetsBindingObserver {
  AuthViewModel() : super(AuthState()) {
    WidgetsBinding.instance.addObserver(this); // Lifecycle observer
    _checkAuthStatus();
    listenToAuthEvents();
    _handleSilentReauth();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _handleSilentReauth();
    }
  }

  StreamSubscription? _subscription;

  Future<void> _handleSilentReauth() async {
    final fedUser = await SecureStorageService().getUser();
    if (fedUser == null) {
      return;
    }

    final success = await FedAuthService().refreshSessionIfNeeded();
    if (success) {
      final user = await SecureStorageService().getUser();
      if (user != null) {
        try {
          final cognitoPlugin = Amplify.Auth.getPlugin(
            AmplifyAuthCognito.pluginKey,
          );

          final fedSession = await cognitoPlugin.federateToIdentityPool(
            token: user.idToken,
            provider: AuthProvider.custom(
              "cognito-idp.ap-southeast-2.amazonaws.com/ap-southeast-2_G4lXj0Yfe",
            ),
          );

          final session = await Amplify.Auth.fetchAuthSession();
          state = state.copyWith(
            isSignedIn: session.isSignedIn,
            user: user.sub,
            email: user.email,
            identityId: fedSession.identityId,
            error: null,
          );
          LoggerService().info("🔁 Session silently refreshed");
        } catch (e) {
          LoggerService().error("🔁 Failed to federate refreshed session: $e");
          state = state.copyWith(isSignedIn: false);
        }
      }
    } else {
      LoggerService().error("🔁 Token refresh failed or expired");
      state = state.copyWith(isSignedIn: false);
    }
  }

  Future<void> federatedSignInWithGoogleCustom() async {
    try {
      var tokenData = await FedAuthService().signInWithHostedUI();
      final identityId = tokenData['identityId'];
      final email = tokenData['email'];
      final sub = tokenData['sub'];

      final Map<String, dynamic> decodedToken = JwtDecoder.decode(
        tokenData['id_token'],
      );
      final exp = decodedToken['exp'];
      final expiryDateTime = DateTime.fromMillisecondsSinceEpoch(
        int.parse(exp.toString()) * 1000,
      );

      final fedUser = FederatedUser(
        sub: sub,
        email: email,
        accessToken: tokenData['access_token'],
        idToken: tokenData['id_token'],
        refreshToken: tokenData['refresh_token'],
        idTokenExpiry: expiryDateTime,
      );

      SecureStorageService().saveUser(fedUser);
      //final storedUser = await SecureStorageService().getUser();
      //LoggerService().info('✅ User saved to secure storage: $storedUser');

      // Not handled by _subscription
      state = state.copyWith(
        isSignedIn: true,
        error: null,
        user: sub,
        email: email,
        identityId: identityId,
      );
    } catch (e) {
      state = state.copyWith(
        isSignedIn: false,
        error: AuthError.fromException(e as Exception).message,
      );
    }
  }

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
      final fedUser = await SecureStorageService().getUser();
      if (fedUser != null) {
        return;
      }

      try {
        final session = await Amplify.Auth.fetchAuthSession();
        LoggerService().info('AuthSession: ${session.toJson()}');
        Map<String, String>? userDetails = await getUserEmailAndSub();
        String identityId = session.toJson()['identityId'] as String? ?? '';

        state = state.copyWith(
          isSignedIn: isSignedIn,
          error: error,
          user: userDetails['sub'],
          email: userDetails['email'],
          identityId: identityId,
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

  Future<void> signOutFederated() async {
    try {
      await GoogleSignIn().signOut();

      final cognitoPlugin = Amplify.Auth.getPlugin(
        AmplifyAuthCognito.pluginKey,
      );
      await cognitoPlugin.clearFederationToIdentityPool();

      // Optional: Also sign out from the social provider SDK
      // await FacebookAuth.instance.logOut();
      // Apple doesn't require manual sign-out (token just expires)

      // Not handled by _subscription
      state = state.copyWith(
        isSignedIn: false,
        error: null,
        user: null,
        email: null,
        identityId: null,
      );
    } catch (e) {
      state = state.copyWith(isSignedIn: false, error: 'Sign out failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await Amplify.Auth.signOut();
      // State change is handled by _subscription

      signOutFederated();
    } catch (e) {
      final authError = AuthError.fromException(e as Exception);
      _updateAuthState(false, authError.message);
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
    state = state.copyWith(error: null, user: state.user, email: state.email);
  }

  void showMessageOnly(String message) {
    state = state.copyWith(
      error: message,
      user: state.user,
      email: state.email,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}








  // Future<void> federatedSignInWithFacebook() async {
  //   try {
  //     await signOutFederated();
  //     await FacebookAuth.instance.logOut();

  //     final LoginResult result = await FacebookAuth.instance.login(
  //       permissions: ['email', 'public_profile'],
  //     );

  //     if (result.status != LoginStatus.success || result.accessToken == null) {
  //       throw Exception('Facebook sign-in failed: ${result.message}');
  //     }

  //     final String token = result.accessToken!.tokenString;

  //     LoggerService().info('Facebook token: $result');

  //     final cognitoPlugin = Amplify.Auth.getPlugin(
  //       AmplifyAuthCognito.pluginKey,
  //     );

  //     final session = await cognitoPlugin.federateToIdentityPool(
  //       token: token,
  //       provider: AuthProvider.facebook,
  //     );

  //     //
  //     final fetchedSession = await Amplify.Auth.fetchAuthSession();
  //     LoggerService().info('✅ Signed in: ${fetchedSession.isSignedIn}');
  //     LoggerService().info('✅ Signed in: $session');
  //     //

  //     LoggerService().info(
  //       'Facebook federated identity session: ${session.toJson()}',
  //     );

  //     final identityId = session.identityId;

  //     state = state.copyWith(
  //       isSignedIn: true,
  //       error: null,
  //       user: identityId,
  //       email: null,
  //       identityId: identityId,
  //     );
  //   } catch (e) {
  //     LoggerService().error('Facebook Federated sign-in failed: $e');
  //     state = state.copyWith(
  //       isSignedIn: false,
  //       error: AuthError.fromException(e as Exception).message,
  //     );
  //   }
  // }

  // Future<void> signInWithWebUIGoogle() async {
  //   try {
  //     final result = await Amplify.Auth.signInWithWebUI(
  //       provider:
  //       //AuthProvider.google,
  //       AuthProvider.custom('accounts.google.com'),
  //     );

  //     if (!result.isSignedIn) {
  //       throw Exception('Google Hosted UI sign-in was unsuccessful.');
  //     }

  //     final session = await Amplify.Auth.fetchAuthSession();
  //     final attributes = await Amplify.Auth.fetchUserAttributes();

  //     String? email;
  //     String? sub;

  //     for (final attr in attributes) {
  //       if (attr.userAttributeKey.key == 'email') {
  //         email = attr.value;
  //       } else if (attr.userAttributeKey.key == 'sub') {
  //         sub = attr.value;
  //       }
  //     }

  //     final identityId = session.toJson()['identityId'] as String? ?? '';

  //     state = state.copyWith(
  //       isSignedIn: true,
  //       error: null,
  //       user: sub,
  //       email: email,
  //       identityId: identityId,
  //     );

  //     LoggerService().info('Google Hosted UI sign-in successful');
  //     LoggerService().info('Google Hosted UI Email: $email');
  //     LoggerService().info('Google Hosted UI Identity ID: $identityId');
  //   } on AuthException catch (e) {
  //     LoggerService().error('Google Hosted UI sign-in failed: ${e.message}');
  //     state = state.copyWith(
  //       isSignedIn: false,
  //       error: AuthError.fromException(e).message,
  //     );
  //   } catch (e) {
  //     LoggerService().error('Google Hosted UI Unexpected error: $e');
  //     state = state.copyWith(isSignedIn: false, error: e.toString());
  //   }
  // }

  // final GoogleSignIn _googleSignIn = GoogleSignIn(
  //   scopes: ['email', 'openid'],
  //   clientId: //serverClientId:
  //       '234674436503-nqtmob8t14lboo0c96e763grkjgedpmb.apps.googleusercontent.com',
  // );

  // Future<void> federatedSignInWithGoogle() async {
  //   try {
  //     await signOutFederated();

  //     final GoogleSignInAccount? account = await _googleSignIn.signIn();
  //     if (account == null) {
  //       throw Exception('Google sign-in aborted');
  //     }

  //     final GoogleSignInAuthentication auth = await account.authentication;

  //     LoggerService().prettyPrint(
  //       '🔑 Google Sign-In Auth: \n'
  //       'idToken=${auth.idToken}, \n'
  //       'accessToken=${auth.accessToken}, \n'
  //       'runTimeType=${auth.runtimeType}, ',
  //     );

  //     final String? idToken = auth.idToken;
  //     if (idToken == null) {
  //       throw Exception('Failed to get Google ID token');
  //     }

  //     final cognitoPlugin = Amplify.Auth.getPlugin(
  //       AmplifyAuthCognito.pluginKey,
  //     );

  //     final session = await cognitoPlugin.federateToIdentityPool(
  //       token: idToken,
  //       provider: AuthProvider.custom(
  //         'accounts.google.com',
  //       ), //AuthProvider.google,
  //     );

  //     // State change is not handled by _subscription
  //     final identityId = session.identityId;
  //     state = state.copyWith(
  //       isSignedIn: true,
  //       error: null,
  //       user: identityId,
  //       email: null, // You can extract this from Google profile if needed
  //       identityId: identityId,
  //     );

  //     LoggerService().info('Federated identity session: ${session.toJson()}');
  //   } catch (e) {
  //     LoggerService().error('Federated sign-in failed: $e');
  //     state = state.copyWith(
  //       isSignedIn: false,
  //       error: AuthError.fromException(e as Exception).message,
  //     );
  //   }
  // }











// jwt token decoded:
// {
//   "iss": "https://accounts.google.com",
//   "azp": "234674436503-91ta2sn2062csbg60l6nckvvlcfvs1f5.apps.googleusercontent.com",
//   "aud": "234674436503-nqtmob8t14lboo0c96e763grkjgedpmb.apps.googleusercontent.com",
//   "sub": "111312505065444776539",
//   "email": "joseph.zhu.jz.game@gmail.com",
//   "email_verified": true,
//   "name": "Joseph Zhu",
//   "picture": "https://lh3.googleusercontent.com/a/ACg8ocLJrfjwHhIQhYQDpu4epnPDwklJfXBwMohTFp2SXFi6QihoCg=s96-c",
//   "given_name": "Joseph",
//   "family_name": "Zhu",
//   "iat": 1743232245,
//   "exp": 1743235845
// }


// Old IAM Trust

// {
// 	"Version": "2012-10-17",
// 	"Statement": [
// 		{
// 			"Effect": "Allow",
// 			"Principal": {
// 				"Federated": "cognito-identity.amazonaws.com"
// 			},
// 			"Action": "sts:AssumeRoleWithWebIdentity",
// 			"Condition": {
// 				"StringEquals": {
// 					"cognito-identity.amazonaws.com:aud": "ap-southeast-2:a9a0bcbb-1156-47eb-9009-63667437aca6"
// 				},
// 				"ForAnyValue:StringLike": {
// 					"cognito-identity.amazonaws.com:amr": "authenticated"
// 				}
// 			}
// 		}
// 	]
// }















  // Future<void> federatedSignInWithApple() async {
  //   try {
  //     final appleCredential = await SignInWithApple.getAppleIDCredential(
  //       scopes: [
  //         AppleIDAuthorizationScopes.email,
  //         AppleIDAuthorizationScopes.fullName,
  //       ],
  //     );

  //     final appleIdToken = appleCredential.identityToken;
  //     if (appleIdToken == null) throw Exception('Apple ID token is null');

  //     final cognitoPlugin = Amplify.Auth.getPlugin(
  //       AmplifyAuthCognito.pluginKey,
  //     );

  //     final session = await cognitoPlugin.federateToIdentityPool(
  //       token: appleIdToken,
  //       provider: AuthProvider.apple,
  //     );

  //     final identityId = session.identityId;
  //     state = state.copyWith(
  //       isSignedIn: true,
  //       user: identityId,
  //       identityId: identityId,
  //       email: null,
  //       error: null,
  //     );
  //   } catch (e) {
  //     state = state.copyWith(
  //       isSignedIn: false,
  //       error: 'Apple Sign-In failed: $e',
  //     );
  //   }
  // }

  // Future<void> federatedSignInWithFacebook() async {
  //   try {
  //     final loginResult =
  //         await FacebookAuth.instance.login(); // Triggers Facebook login flow

  //     if (loginResult.status != LoginStatus.success) {
  //       throw Exception('Facebook login failed: ${loginResult.message}');
  //     }

  //     final accessToken = loginResult.accessToken?.token;
  //     if (accessToken == null) throw Exception('Facebook access token is null');

  //     final cognitoPlugin = Amplify.Auth.getPlugin(
  //       AmplifyAuthCognito.pluginKey,
  //     );

  //     final session = await cognitoPlugin.federateToIdentityPool(
  //       token: accessToken,
  //       provider: AuthProvider.facebook,
  //     );

  //     final identityId = session.identityId;
  //     state = state.copyWith(
  //       isSignedIn: true,
  //       user: identityId,
  //       identityId: identityId,
  //       email: null,
  //       error: null,
  //     );
  //   } catch (e) {
  //     state = state.copyWith(
  //       isSignedIn: false,
  //       error: 'Facebook Sign-In failed: $e',
  //     );
  //   }
  // }