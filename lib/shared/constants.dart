import 'package:flutter/material.dart';

class Constants {
  static String appId = '1:682306844850:web:d810725598cc077bd571ab';
  static String apiKey = 'AIzaSyDIX6hdroDY2nDgmqah5IrjQPQ5iHyqr0o';
  static String messagingSenderId = '682306844850';
  static String projectId = 'groupie-e4ed1';
  static const primaryColor = Color(0xFFee7b64);

  static void nextScreen(context, page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  static void nextScreenReplace(context, page) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => page));
  }
}
