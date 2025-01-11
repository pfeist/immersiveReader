import 'package:flutter/material.dart';
import 'package:immersive_reader/models/book.dart'; 
import 'package:immersive_reader/repositories/book_repository.dart'; 
import 'package:immersive_reader/utils/bookmark_manager.dart';
import 'package:immersive_reader/screens/reader/reader_screen.dart';
//import 'package:immersive_reader/screens/reader/epub_screen.dart'; 
// import your PDF screen once you have it

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final BookRepository _bookRepo = BookRepository();
  final BookmarkManager _bookmarkManager = BookmarkManager();
  late Future<List<Book>> _futureBooks;

  @override
  void initState() {
    super.initState();
    _futureBooks = _bookRepo.loadLibrary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library'),
      ),
      body: FutureBuilder<List<Book>>(
        future: _futureBooks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No books in library'));
          }
          final books = snapshot.data!;
          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return ListTile(
                title: Text(book.title),
                subtitle: Text(book.fileType),
                onTap: () {
                   //Open the book in ReaderScreen
                   //e.g.:
                   Navigator.push(context, MaterialPageRoute(
                     builder: (context) => ReaderScreen(filePath: book.filePath),
                   ));
                },
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deleteBook(book);
                    } else if (value == 'clear') {
                      _clearReadingHistory(book);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'clear',
                      child: Text('Clear Reading History'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete from Library'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _deleteBook(Book book) async {
    final books = await _bookRepo.loadLibrary();
    books.removeWhere((b) => b.filePath == book.filePath);
    await _bookRepo.saveLibrary(books);

    setState(() {
      _futureBooks = _bookRepo.loadLibrary();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${book.title} removed from library')),
    );
  }

  Future<void> _clearReadingHistory(Book book) async {
    await _bookmarkManager.clearReadingRatio(book.filePath);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reading history cleared for "${book.title}"')),
    );
  }
}
