import 'package:shared_preferences/shared_preferences.dart';

class BookmarkManager {
  Future<void> saveBookmark(String chapterId, int page) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('bookmark_$chapterId', page);
  }

  Future<int?> getBookmark(String chapterId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('bookmark_$chapterId');
  }
}
