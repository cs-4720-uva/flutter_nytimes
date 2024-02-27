class Book {
  int rank;
  String title;
  String author;
  String imageUrl;
  String description;
  String amazonLink;

  Book({
    required this.rank,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.description,
    required this.amazonLink,
  });


  @override
  String toString() {
    return 'Book{'
        '\n\trank: $rank, '
        '\n\ttitle: $title, '
        '\n\tauthor: $author, '
        '\n\timageUrl: $imageUrl, '
        '\n\tdescription: $description, '
        '\n\tamazonLink: $amazonLink}';
  }

  factory Book.fromJson(Map<String, dynamic> json) {
      return Book(
        rank: json["rank"] as int,
        title: json["title"] as String,
        author: json["author"] as String,
        imageUrl: json["book_image"] as String,
        description: json["description"] as String,
        amazonLink: json["amazon_product_url"] as String,
      );
    }
}
