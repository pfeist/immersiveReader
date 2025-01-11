import 'package:flutter/material.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChapterScreen extends StatefulWidget {
  final EpubChapter chapter;

  const ChapterScreen({Key? key, required this.chapter}) : super(key: key);

  @override
  _ChapterScreenState createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  final ScrollController _scrollController = ScrollController();
  
  // Track ratio and whether we’re restoring
  bool _isRestoringPosition = false;
  double fontSize = 18.0;

  @override
  void initState() {
    super.initState();
    _loadBookmarkRatio();
    _scrollController.addListener(_onScroll);
  }

  // We remove or adapt didChangeDependencies if not needed

  // 1. LOAD the ratio from SharedPreferences
  Future<void> _loadBookmarkRatio() async {
    final bookmarkManager = BookmarkManager();
    final savedRatio = await bookmarkManager.getBookmarkRatio(widget.chapter.Title!);

    // We'll restore after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && savedRatio != null) {
        _isRestoringPosition = true;
        final maxScroll = _scrollController.position.maxScrollExtent;
        final targetOffset = savedRatio * maxScroll;
        _scrollController.jumpTo(targetOffset);
        _isRestoringPosition = false;
      }
    });
  }

  // 2. LISTEN to scroll changes and save ratio
  void _onScroll() {
    if (_isRestoringPosition) return;
    final maxScroll = _scrollController.position.maxScrollExtent;

    if (maxScroll <= 0) {
      // Edge case: if there's not enough text, maxScroll might be 0
      return;
    }

    final offset = _scrollController.offset;
    final ratio = offset / maxScroll; 
    _saveBookmarkRatio(ratio);
  }

  Future<void> _saveBookmarkRatio(double ratio) async {
    final bookmarkManager = BookmarkManager();
    bookmarkManager.saveBookmarkRatio(widget.chapter.Title!, ratio);
  }

  // Adjust the font size, and attempt to restore approximate ratio
  void _adjustFontSize(double newSize) {
    // 1. Capture current ratio before we change font size
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentOffset = _scrollController.offset;
    final oldRatio = maxScroll > 0 ? currentOffset / maxScroll : 0.0;
    
    setState(() {
      fontSize = newSize;
    });
    
    // 2. After the layout updates, try jumping to the approximate new ratio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final newMaxScroll = _scrollController.position.maxScrollExtent;
      final newOffset = oldRatio * newMaxScroll;
      _scrollController.jumpTo(newOffset);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapter.Title ?? 'Untitled Chapter'),
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
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Html(
          data: widget.chapter.HtmlContent,
          style: {
            "body": Style(fontSize: FontSize(fontSize)),
          },
        ),
      ),
    );
  }
}

// MANAGER class for bookmarks by ratio
class BookmarkManager {
  Future<void> saveBookmarkRatio(String chapterTitle, double ratio) async {
    final prefs = await SharedPreferences.getInstance();
    // e.g. store under "ratio_<chapterTitle>"
    prefs.setDouble('ratio_$chapterTitle', ratio);
  }

  Future<double?> getBookmarkRatio(String chapterTitle) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('ratio_$chapterTitle');
  }
}
