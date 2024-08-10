import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';  // Import the file_picker package
import 'package:immersive_reader/screens/epub_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter eBook Reader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          accentColor: Colors.amber,  // accentColor is used within colorScheme
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 16.0),
          displayLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blue,
          textTheme: ButtonTextTheme.primary,
        ),
        appBarTheme: AppBarTheme(
          color: Colors.blue,  // Set a universal color for app bars
        ),
      ),
        // Add more theme customizations as needed
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('eBook Reader')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['pdf', 'epub'],
            );

            if (result != null) {
              String filePath = result.files.single.path!;
              String fileExtension = filePath.split('.').last;

              if (fileExtension == 'pdf') {
                // Navigate to PDF Screen
              } else if (fileExtension == 'epub') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EpubScreen(path: filePath),
                  ),
                );
              }
            }
          },
          child: Text('Open eBook'),
        ),
      ),
    );
  }
}
