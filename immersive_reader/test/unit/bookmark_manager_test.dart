import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:immersive_reader/screens/reader/chapter_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BookmarkManager', () {
    test('save and retrieve bookmark', () async {
      SharedPreferences.setMockInitialValues({});
      final bookmarkManager = BookmarkManager();

      await bookmarkManager.saveBookmark('Test Chapter', 5);
      final int? bookmark = await bookmarkManager.getBookmark('Test Chapter');

      expect(bookmark, 5);
    });

    test('retrieve non-existent bookmark', () async {
      SharedPreferences.setMockInitialValues({});
      final bookmarkManager = BookmarkManager();

      final int? bookmark = await bookmarkManager.getBookmark('Non-existent Chapter');

      expect(bookmark, null);
    });
  });
}
