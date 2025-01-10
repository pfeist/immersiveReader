// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChapterScreen extends StatefulWidget {
  final EpubChapter chapter;

  const ChapterScreen({super.key, required this.chapter});

  @override
  _ChapterScreenState createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  int currentPage = 0;
  double fontSize = 18.0; // Default font size
  List<String> pages = [];

  @override
  void initState() {
    super.initState();
    _loadBookmark();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _paginateText(widget.chapter.HtmlContent!);
  }

void _paginateText(String text) {
  print("Starting pagination");

  // Configurable padding value to adjust how much height is reserved
  double verticalPadding = 10.0;  // Reduced padding
  double maxHeight = MediaQuery.of(context).size.height - verticalPadding;
  double maxWidth = MediaQuery.of(context).size.width - 40;

  List<String> words = text.split(' ');
  StringBuffer pageBuffer = StringBuffer();
  TextPainter tp = TextPainter(
    textDirection: TextDirection.ltr,
  );

  pages.clear(); // Clear previous pages

  for (int i = 0; i < words.length; i++) {
    pageBuffer.write("${words[i]} ");
    tp.text = TextSpan(text: pageBuffer.toString(), style: TextStyle(fontSize: fontSize));
    tp.layout(maxWidth: maxWidth);

    if (tp.height > maxHeight) {
      String lastWord = words[i];
      //pageBuffer.write(lastWord);
      pages.add(pageBuffer.toString().trim());

      pageBuffer.clear();
      pageBuffer.write(lastWord + " ");
    }
  }

  if (pageBuffer.isNotEmpty) {
    pages.add(pageBuffer.toString().trim());
  }

  print("Pagination complete. Total pages: ${pages.length}");
}



  void _loadBookmark() async {
    final bookmarkManager = BookmarkManager();
    int? savedPage = await bookmarkManager.getBookmark(widget.chapter.Title!);
    if (savedPage != null) {
      setState(() {
        currentPage = savedPage;
      });
    }
  }

  void _saveBookmark() {
    final bookmarkManager = BookmarkManager();
    bookmarkManager.saveBookmark(widget.chapter.Title!, currentPage);
  }

  @override
  void dispose() {
    _saveBookmark(); // Save bookmark when user leaves the screen
    super.dispose();
  }

  void _adjustFontSize(double newSize) {
    setState(() {
      fontSize = newSize;
      _paginateText(widget.chapter.HtmlContent!); // Re-paginate with new font size
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapter.Title!),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: _saveBookmark,
          ),
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Adjust Font Size'),
                    content: Slider(
                      min: 12.0,
                      max: 30.0,
                      value: fontSize,
                      onChanged: (value) {
                        _adjustFontSize(value);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Html(
                data: pages.isNotEmpty ? pages[currentPage] : '',
                style: {
                  "body": Style(fontSize: FontSize(fontSize)),
                },
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: currentPage > 0
                    ? () {
                        setState(() {
                          currentPage--;
                        });
                      }
                    : null,
                child: const Text('Previous'),
              ),
              ElevatedButton(
                onPressed: currentPage < pages.length - 1
                    ? () {
                        setState(() {
                          currentPage++;
                        });
                      }
                    : null,
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BookmarkManager {
  Future<void> saveBookmark(String chapterTitle, int page) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('bookmark_$chapterTitle', page);
  }

  Future<int?> getBookmark(String chapterTitle) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('bookmark_$chapterTitle');
  }
}
