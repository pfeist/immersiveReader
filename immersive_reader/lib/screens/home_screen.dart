import 'package:flutter/material.dart';
import 'package:immersive_reader/styles/styles.dart';  // Import the styles
import 'package:file_picker/file_picker.dart'; 
import 'package:immersive_reader/screens/epub_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('eBook Reader', style: headlineStyle),
        ),
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
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(
                    builder: (context) => EpubScreen(path: filePath),
                  ),
                );
              }
            }
          },
          style: buttonStyle,  // Use global button style
          child: const Text('Open eBook', style: bodyTextStyle),  // Use global style
        ),
      ),
    );
  }
}