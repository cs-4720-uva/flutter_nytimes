enum NYTimesList {
  combinedFiction(
    encodedName: "combined-print-and-e-book-fiction",
    displayName: "Combined - Fiction",
  ),
  combinedNonFiction(
    encodedName: "combined-print-and-e-book-nonfiction",
    displayName: "Combined - Non-Fiction",
  ),
  hardcoverFiction(
    encodedName: "hardcover-fiction",
    displayName: "Hardcover - Fiction",
  ),
  hardcoverNonFiction(
    encodedName: "hardcover-nonfiction",
    displayName: "Hardcover - Non-Fiction",
  ),
  paperbackFiction(
    encodedName: "trade-fiction-paperback",
    displayName: "Paperback - Fiction",
  ),
  paperbackNonFiction(
    encodedName: "paperback-nonfiction",
    displayName: "Paperback - Non-Fiction",
  );

  const NYTimesList({
    required this.encodedName,
    required this.displayName,
  });

  final String encodedName;
  final String displayName;
}
