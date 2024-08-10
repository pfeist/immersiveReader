import 'package:flutter/material.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter_html/flutter_html.dart';  // Import flutter_html package

class ChapterScreen extends StatelessWidget {
  final EpubChapter chapter;

  ChapterScreen({required this.chapter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(chapter.Title!)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chapter.Title!,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Html(data: chapter.HtmlContent!), // Render HTML content
          ],
        ),
      ),
    );
  }
}
