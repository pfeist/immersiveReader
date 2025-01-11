import 'dart:convert';
import 'package:immersive_reader/models/book.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookRepository {
  static const _libraryKey = 'library_books';

  Future<List<Book>> loadLibrary() async {
    final prefs = await SharedPreferences.getInstance();
    final booksJson = prefs.getString(_libraryKey);
    if (booksJson == null) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(booksJson);
    return decoded.map((b) => Book(
      title: b['title'],
      filePath: b['filePath'],
      fileType: b['fileType'],
    )).toList();
  }

  Future<void> saveLibrary(List<Book> books) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(books.map((b) => {
      'title': b.title,
      'filePath': b.filePath,
      'fileType': b.fileType,
    }).toList());

    await prefs.setString(_libraryKey, encoded);
  }
}

