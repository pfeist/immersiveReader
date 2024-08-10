import 'package:flutter/material.dart';
import 'package:immersive_reader/styles/styles.dart';  // Import the styles

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home', style: headlineStyle),  // Use global style
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {},
          child: Text('Click Me', style: bodyTextStyle),  // Use global style
          style: buttonStyle,  // Use global button style
        ),
      ),
    );
  }
}
