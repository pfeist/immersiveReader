import 'dart:io';
import 'package:flutter/material.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReaderScreen extends StatefulWidget {
  final String filePath;

  const ReaderScreen({Key? key, required this.filePath}) : super(key: key);

  @override
  _ReaderScreenState createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final ScrollController _scrollController = ScrollController();

  double fontSize = 18.0;
  bool _isRestoringPosition = false;
  String combinedHtml = ''; // For the single-string approach

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadEpubData(widget.filePath);
  }

  Future<void> _loadEpubData(String path) async {
    try {
      final epubBytes = await File(path).readAsBytes();
      final epubBook = await EpubReader.readBook(epubBytes);

      // Flatten all chapters
      final flatChapters = _flattenChapters(epubBook.Chapters);

      // Combine them into one big HTML string (with titles)
      final bigHtml = _combineAllChapters(flatChapters);

      setState(() {
        combinedHtml = bigHtml;
      });

      // Wait for the widget to build, then load last scroll position
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _restoreScrollPosition();
      });
    } catch (e) {
      print("Error loading ePub: $e");
    }
  }

  Future<void> _restoreScrollPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final ratio = prefs.getDouble('readingRatio_${widget.filePath}') ?? 0.0;

    if (ratio > 0) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final targetOffset = ratio * maxScroll;
      _isRestoringPosition = true;
      _scrollController.jumpTo(targetOffset);
      _isRestoringPosition = false;
    }
  }

  void _onScroll() {
    if (_isRestoringPosition) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;

    final offset = _scrollController.offset;
    final ratio = offset / maxScroll;
    _saveRatio(ratio);
  }

  Future<void> _saveRatio(double ratio) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('readingRatio_${widget.filePath}', ratio);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _adjustFontSize(double newSize) {
    // Capture current scroll ratio
    final oldRatio = _scrollController.offset / (_scrollController.position.maxScrollExtent > 0
      ? _scrollController.position.maxScrollExtent
      : 1);

    setState(() {
      fontSize = newSize;
    });

    // After re-layout, jump to approximate position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newMax = _scrollController.position.maxScrollExtent;
      final newOffset = oldRatio * newMax;
      _scrollController.jumpTo(newOffset);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Epub Reader'),
        actions: [
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
      body: combinedHtml.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Html(
                data: combinedHtml,
                style: {
                  "body": Style(fontSize: FontSize(fontSize)),
                  "h2": Style(fontSize: FontSize(fontSize + 4), fontWeight: FontWeight.bold),
                },
              ),
            ),
    );
  }

  // Flatten nested chapters
  List<EpubChapter> _flattenChapters(List<EpubChapter>? chapters) {
    final List<EpubChapter> flatList = [];
    if (chapters == null) return flatList;

    for (final chapter in chapters) {
      flatList.add(chapter);
      flatList.addAll(_flattenChapters(chapter.SubChapters));
    }
    return flatList;
  }

  // Combine chapters into a single HTML string
  String _combineAllChapters(List<EpubChapter> chapters) {
    final buffer = StringBuffer();
    for (int i = 0; i < chapters.length; i++) {
      final title = chapters[i].Title ?? 'Chapter ${i + 1}';
      final content = chapters[i].HtmlContent ?? '';
      buffer.write('<h2>$title</h2>');
      buffer.write(content);
    }
    return buffer.toString();
  }
}
