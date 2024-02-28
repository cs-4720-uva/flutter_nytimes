enum NYTimesList {
  COMBINED_FICTION(
    encodedName: "combined-print-and-e-book-fiction",
    displayName: "Combined - Fiction",
  ),
  COMBINED_NON_FICTION(
    encodedName: "combined-print-and-e-book-nonfiction",
    displayName: "Combined - Non-Fiction",
  ),
  HARDCOVER_FICTION(
    encodedName: "hardcover-fiction",
    displayName: "Hardcover - Fiction",
  ),
  HARDCOVER_NONFICTION(
    encodedName: "hardcover-nonfiction",
    displayName: "Hardcover - Non-Fiction",
  ),
  PAPERBACK_FICTION(
    encodedName: "trade-fiction-paperback",
    displayName: "Paperback - Fiction",
  ),
  PAPERBACK_NONFICTION(
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
