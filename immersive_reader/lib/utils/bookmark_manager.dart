import 'package:shared_preferences/shared_preferences.dart';

class BookmarkManager {
  Future<void> saveReadingRatio(String filePath, double ratio) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('readingRatio_$filePath', ratio);
  }

  Future<double?> getReadingRatio(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('readingRatio_$filePath');
  }

  Future<void> clearReadingRatio(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('readingRatio_$filePath');
  }
}
