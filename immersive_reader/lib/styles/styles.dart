// lib/styles/styles.dart

import 'package:flutter/material.dart';

const Color primaryColor = Colors.blue;
const Color accentColor = Colors.amber;

const TextStyle headlineStyle = TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold);
const TextStyle bodyTextStyle = TextStyle(fontSize: 16.0, color: Colors.white);  // Set text color here

final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
  backgroundColor: primaryColor,  // Set button background color
  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
  textStyle: const TextStyle(fontSize: 18.0),
);
