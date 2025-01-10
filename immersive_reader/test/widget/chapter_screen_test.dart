import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:immersive_reader/screens/reader/chapter_screen.dart';
import 'package:epubx/epubx.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChapterScreen', () {
    late EpubChapter testChapter;

    setUp(() {
      testChapter = EpubChapter(
        Title: 'Test Chapter',
        HtmlContent: '<p>This is a test paragraph for pagination.</p>',
      );
    });

    testWidgets('loads and displays chapter content', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ChapterScreen(chapter: testChapter),
      ));

      expect(find.text('Test Chapter'), findsOneWidget);
      expect(find.text('This is a test paragraph for pagination.'), findsOneWidget);
    });

    testWidgets('adjusts font size and re-paginates text', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ChapterScreen(chapter: testChapter),
      ));

      // Trigger font size adjustment
      await tester.tap(find.byIcon(Icons.text_fields));
      await tester.pump();
      
      await tester.drag(find.byType(Slider), Offset(30.0, 0.0));
      await tester.pump();

      expect(find.text('This is a test paragraph for pagination.'), findsOneWidget);
    });

    testWidgets('navigates between pages', (WidgetTester tester) async {
      // Modify the test chapter content to ensure it will paginate
      testChapter.HtmlContent = '<p>${'This is a test paragraph. ' * 50}</p>';

      await tester.pumpWidget(MaterialApp(
        home: ChapterScreen(chapter: testChapter),
      ));

      expect(find.text('This is a test paragraph.'), findsWidgets);

      // Navigate to next page
      await tester.tap(find.text('Next'));
      await tester.pump();

      expect(find.text('This is a test paragraph.'), findsWidgets);

      // Navigate to previous page
      await tester.tap(find.text('Previous'));
      await tester.pump();

      expect(find.text('This is a test paragraph.'), findsWidgets);
    });
  });
}
