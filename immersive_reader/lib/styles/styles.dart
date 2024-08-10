// lib/styles/styles.dart

import 'package:flutter/material.dart';

final Color primaryColor = Colors.blue;
final Color accentColor = Colors.amber;

final TextStyle headlineStyle = TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold);
final TextStyle bodyTextStyle = TextStyle(fontSize: 16.0);

final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
  backgroundColor: primaryColor,  // Use backgroundColor instead of primary
  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
  textStyle: TextStyle(fontSize: 18.0),
);
