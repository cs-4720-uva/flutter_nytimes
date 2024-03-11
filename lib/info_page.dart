import 'package:flutter/material.dart';
import 'package:nytimes_bestsellers/data/book.dart';
import 'package:nytimes_bestsellers/main.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPage extends StatelessWidget {
  const InfoPage(this._book, {super.key});

  final Book _book;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("NY Times Best-Sellers"),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context, _book);
                },
                child: const Icon(Icons.exit_to_app, size: 26.0),
              ))
        ], // actions
      ),
      body: Scrollbar(
        child: Column(
          children: [
            bookCoverImage(_book),
            bookTitleAndAuthor(_book),
            const Divider(thickness: 1),
            Text(_book.description),
            ElevatedButton(
                onPressed: () async { _launchUrl(_book.amazonLink); },
                child: const Text("Amazon")
            )
        ],
        )
      ),
    );
  }

  _launchUrl(String uri) async {
    final Uri url = Uri.parse(uri);
    if (!await launchUrl(url)) {
      throw "Could not launch uri";
    }
  }
}