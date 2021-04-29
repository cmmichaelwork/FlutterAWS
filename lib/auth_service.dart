import 'dart:async';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

import 'auth_credentials.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

// 1
enum AuthFlowStatus { login, signUp, verification, session }

// 2
class AuthState {
  final AuthFlowStatus authFlowStatus;

  AuthState({this.authFlowStatus});
}

// 3
class AuthService {
  // 4
  final authStateController = StreamController<AuthState>();
  AuthCredentials _credentials;
  // 5
  void showSignUp() {
    final state = AuthState(authFlowStatus: AuthFlowStatus.signUp);
    authStateController.add(state);
  }

  // 6
  void showLogin() {
    final state = AuthState(authFlowStatus: AuthFlowStatus.login);
    authStateController.add(state);
  }
  // showLogin closing }

// 1
  void loginWithCredentials(AuthCredentials credentials) async {
    //  final state = AuthState(authFlowStatus: AuthFlowStatus.session);
    // authStateController.add(state);
    try {
      //2
      //
      logOut(); //new
      final result = await Amplify.Auth.signIn(
          username: credentials.username, password: credentials.password);
      //3
      if (result.isSignedIn) {
        final state = AuthState(authFlowStatus: AuthFlowStatus.session);
        authStateController.add(state);
      } else {
        //4
        print('User could not be signed in');
      }
    } on AuthException catch (authError) {
      print('Could not login - ${authError}');
    }
  }

// 2
// 1
  void signUpWithCredentials(SignUpCredentials credentials) async {
    try {
      // 2
      final userAttributes = {'email': credentials.email};

      // 3
      final result = await Amplify.Auth.signUp(
          username: credentials.username,
          password: credentials.password,
          options: CognitoSignUpOptions(userAttributes: userAttributes));

      // 4
      if (result.isSignUpComplete) {
        loginWithCredentials(credentials);
      } else {
        // 5
        this._credentials = credentials;

        // 6
        final state = AuthState(authFlowStatus: AuthFlowStatus.verification);
        authStateController.add(state);
      }

      // 7
    } on AuthException catch (authError) {
      print('Failed to sign up - ${authError}');
    }
  }

  void verifyCode(String verificationCode) async {
//    final state = AuthState(authFlowStatus: AuthFlowStatus.session);
//    authStateController.add(state);
    // }
// AuthService closing }

    try {
      //2
      final result = await Amplify.Auth.confirmSignUp(
          username: _credentials.username, confirmationCode: verificationCode);
      //3
      if (result.isSignUpComplete) {
        loginWithCredentials(_credentials);
      } else {
        //4
        //Follow more steps
      }
    } on AuthException catch (authError) {
      print('Could not verify code - ${authError}');
    }
  }

  void logOut() async {
    try {
      //1
      log('data Test');
      await Amplify.Auth.signOut();
      //2
      showLogin();
    } on AuthException catch (authError) {
      print('Could not log out - ${authError}');
    }
  }

  void checkAuthStatus() async {
    try {
      await Amplify.Auth.fetchAuthSession();
      final state = AuthState(authFlowStatus: AuthFlowStatus.session);
      authStateController.add(state);
    } catch (_) {
      final state = AuthState(authFlowStatus: AuthFlowStatus.login);
      authStateController.add(state);
    }
  }
}
