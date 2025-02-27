import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:swyp_ai/utils/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;


class GoogleServices {
  static final _googleSignIn = GoogleSignIn();

  static Future<void> loginWithGoogle() async {
    try {
      GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      AppLogger.debug('Google Sign In Account: $googleSignInAccount');
      if (googleSignInAccount != null) {
        var uri = dotenv.env['URI'];
        http.Response response = await http.post(
            Uri.parse('${uri}/googlelogin'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              "googleId": googleSignInAccount.id,
              "username": "user" + googleSignInAccount.id.substring(0, 5),
              "password": "googleAuth",
            })
        );
        AppLogger.debug('Response: ${response.body}');
      }
    } on Exception catch (e) {
      AppLogger.error('Error signing in with Google: $e');
      // TODO
    }
  }


  static Future<void> registerWithGoogle() async {
    try {
      GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      AppLogger.debug('Google Sign In Account: $googleSignInAccount');
      if (googleSignInAccount != null) {
        var uri = dotenv.env['URI'];
        http.Response response = await http.post(
            Uri.parse('${uri}/googleRegister'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              "googleId": googleSignInAccount.id,
              "username": "user" + googleSignInAccount.id.substring(0, 5),
              "password": "googleAuth",
            })
        );
        AppLogger.debug('Response: ${response.body}');
      }
    } on Exception catch (e) {
      AppLogger.error('Error signing in with Google: $e');
      // TODO
    }
  }
  static Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect();
    } on Exception catch (e) {
      AppLogger.error('Error signing out with Google: $e');
      // TODO
    }
  }
}
