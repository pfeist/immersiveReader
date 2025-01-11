import 'package:flutter/material.dart';
import 'package:epubx/epubx.dart';
import 'dart:io';  
import 'package:immersive_reader/screens/reader/reader_screen.dart';

class EpubScreen extends StatefulWidget {
  final String path;

  const EpubScreen({super.key, required this.path});

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
      appBar: AppBar(title: const Text('EPUB Reader')),
      body: FutureBuilder<EpubBook>(
        future: _futureBook,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              // If we successfully loaded the EPUB, show a button
              // to open ReaderScreen (continuous reading)
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to continuous ReaderScreen with the file path
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReaderScreen(
                          filePath: widget.path,
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Entire Book'),
                ),
              );
            } else {
              return const Center(child: Text('Error loading EPUB'));
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<EpubBook> _openEpub(String path) async {
    final epubBytes = await File(path).readAsBytes();
    final epubBook = await EpubReader.readBook(epubBytes);
    return epubBook;
  }
}
