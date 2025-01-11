import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:immersive_reader/models/book.dart';
import 'package:immersive_reader/repositories/book_repository.dart';
import 'package:immersive_reader/screens/reader/epub_screen.dart';
import 'package:immersive_reader/screens/library_screen.dart';
import 'package:immersive_reader/styles/styles.dart';
import 'package:immersive_reader/widgets/custom_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BookRepository _bookRepository = BookRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('eBook Reader', style: headlineStyle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1) "Add Book" button using your CustomButton
            CustomButton(
              text: 'Add Book to Library',
              onPressed: _addBookToLibrary,
            ),

            const SizedBox(height: 16),

            // 2) "Open eBook" button using your CustomButton 
            // (if you still want a direct open approach)
            CustomButton(
              text: 'Open Library',
              onPressed: _goToLibrary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addBookToLibrary() async {
    // 1. Pick the file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'epub'],
    );

    if (result != null && result.files.isNotEmpty) {
      String filePath = result.files.single.path!;
      String fileExtension = filePath.split('.').last.toLowerCase();

      // 2. Create a Book object
      final title = _extractBookTitle(filePath);
      final book = Book(
        title: title,
        filePath: filePath,
        fileType: fileExtension, // 'pdf' or 'epub'
      );

      // 3. Load, update, and save library
      final existingBooks = await _bookRepository.loadLibrary();
      // You might check if the book is already in the library, if you want to avoid duplicates.
      existingBooks.add(book);
      await _bookRepository.saveLibrary(existingBooks);

      // 4. Optionally, give feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$title added to library')),
      );

       //5. Navigate to the library screen
       Navigator.push(
         context,
         MaterialPageRoute(builder: (context) => const LibraryScreen()),
       );
    }
  }

  Future<void> _goToLibrary() async{
    Navigator.push(
         context,
         MaterialPageRoute(builder: (context) => const LibraryScreen()),
    );
  }

  Future<void> _openEbookDirect() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'epub'],
    );

    if (result != null && result.files.isNotEmpty) {
      String filePath = result.files.single.path!;
      String fileExtension = filePath.split('.').last.toLowerCase();

      if (fileExtension == 'pdf') {
        // Navigate to PDF Screen
      } else if (fileExtension == 'epub') {
        // Directly open the selected file in EpubScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EpubScreen(path: filePath),
          ),
        );
      }
    }
  }

  // Extract a simple "title" from the file path 
  // (You could parse real metadata from EPUB if needed)
  String _extractBookTitle(String filePath) {
    // Example: /storage/emulated/0/Download/MyBook.epub
    // We'll just grab the filename without extension
    final splitted = filePath.split(RegExp(r'[/\\]')); 
    final filename = splitted.last; // MyBook.epub
    return filename.replaceAll('.epub', '').replaceAll('.pdf', '');
  }
}
