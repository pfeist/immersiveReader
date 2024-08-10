import 'package:flutter/material.dart';
import 'package:epubx/epubx.dart';
import 'chapter_screen.dart';
import 'dart:io';  // Import dart:io for File operations

class EpubScreen extends StatefulWidget {
  final String path;

  EpubScreen({required this.path});

  @override
  _EpubScreenState createState() => _EpubScreenState();
}

class _EpubScreenState extends State<EpubScreen> {
  late Future<EpubBook> _futureBook;

  @override
  void initState() {
    super.initState();
    _futureBook = _openEpub(widget.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('EPUB Reader')),
      body: FutureBuilder<EpubBook>(
        future: _futureBook,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return _buildEpubContent(snapshot.data!);
            } else {
              return Center(child: Text('Error loading EPUB'));
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildEpubContent(EpubBook book) {
    final chapters = book.Chapters;

    return ListView.builder(
      itemCount: chapters!.length,
      itemBuilder: (context, index) {
        final chapter = chapters[index];
        return ListTile(
          title: Text(chapter.Title!),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChapterScreen(chapter: chapter),
              ),
            );
          },
        );
      },
    );
  }

  Future<EpubBook> _openEpub(String path) async {
    final epubBytes = await File(path).readAsBytes();  // Ensure File is correctly used here
    final epubBook = await EpubReader.readBook(epubBytes);
    return epubBook;
  }
}
