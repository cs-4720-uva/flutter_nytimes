class Book {
  int isbn; // dart int is 64-bit, not 32-bit, so this is okay
  String title;
  String author;
  String imageUrl;
  String description;
  String amazonLink;

  Book({
    required this.isbn,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.description,
    required this.amazonLink,
  });


  @override
  String toString() {
    return 'Book{'
        '\n\tisbn: $isbn, '
        '\n\ttitle: $title, '
        '\n\tauthor: $author, '
        '\n\timageUrl: $imageUrl, '
        '\n\tdescription: $description, '
        '\n\tamazonLink: $amazonLink}\n';
  }

  factory Book.fromDBResult(Map<String, dynamic> result) {
    return Book(
      isbn: result["isbn"] as int,
      title: result["title"] as String,
      author: result["author"] as String,
      imageUrl: result["imageUrl"] as String,
      description: result["description"] as String,
      amazonLink: result["amazonLink"] as String,
    );
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      isbn: int.parse(json["primary_isbn13"] as String),
      title: json["title"] as String,
      author: json["author"] as String,
      imageUrl: json["book_image"] as String,
      description: json["description"] as String,
      amazonLink: json["amazon_product_url"] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "isbn": isbn,
      "title": title,
      "author": author,
      "imageUrl": imageUrl,
      "description": description,
      "amazonLink": amazonLink,
    };
  }

  @override
  bool operator ==(Object other) {
    return (other is Book) && other.isbn == isbn;
  }

  @override
  int get hashCode => isbn;

}
