import 'package:http/http.dart' as http;
import 'package:nytimes_bestsellers/data/book.dart';
import 'dart:convert';

import 'package:nytimes_bestsellers/data/bestseller_categories.dart';

const apiKey = String.fromEnvironment("NY_TIMES_KEY");

class NYTimesBestSellersReader {
  Future<List<Book>> getBooks(
      {BestSellerCategories list = BestSellerCategories.combinedFiction}
  ) async {
    final response = await http.get(
        Uri.parse(
            "https://api.nytimes.com/svc/books/v3/lists/${list.encodedName}?api-key=$apiKey")
    );
    var b = json.decode(response.body);
    List<Book> books = [];
    for (int i = 0; i < 15; i++) {
      books.add(Book.fromJson(b["results"]["books"][i]));
    }
    return books;
  }
}