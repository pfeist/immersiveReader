// lib/models/book.dart
class Book {
  final String title;
  final String filePath;
  final String fileType; // 'pdf' or 'epub'

  Book({
    required this.title,
    required this.filePath,
    required this.fileType,
  });

  // Optional: convenience constructor or fromJson/toJson methods
}
