import 'models.dart';

class Library {
  final List<LibraryItem> items = [];

  late final DateTime openedAt;
  String? _cachedReport;

  void open() {
    openedAt = DateTime.now();
  }

  void add(LibraryItem item) {
    items.add(item);
  }

  Book? findByTitle(String title) {
    for (final item in items) {
      if (item is Book && item.title == title) {
        return item;
      }
    }
    return null;
  }

  String countryOf(String title) {
    final book = findByTitle(title);
    final country = book?.author.country;
    return country ?? 'unknown';
  }

  String get report {
    _cachedReport ??= buildReport();
    return _cachedReport ?? 'Empty report';
  }

  String buildReport() => 'Library report generated at ${openedAt.toIso8601String()}';

  // Level 4 Queries
  Iterable<String> get everyTitle => items.map((e) => e.title);

  Iterable<Book> get booksPublishedAfter2010 =>
      items.whereType<Book>().where((b) => b.year > 2010);

  // fold accepts an initial value (0.0), making it safe for empty collections where reduce would throw an exception
  double get averagePageCount {
    final books = items.whereType<Book>();
    if (books.isEmpty) return 0.0;
    final totalPages = books.fold<int>(0, (sum, b) => sum + b.pages);
    return totalPages / books.length;
  }

  Map<String, int> get authorBookCount => items.whereType<Book>().fold<Map<String, int>>(
    {},
        (map, b) {
      map[b.author.name] = (map[b.author.name] ?? 0) + 1;
      return map;
    },
  );

  Set<String> get distinctAuthorNames =>
      items.whereType<Book>().map((b) => b.author.name).toSet();

  Set<Genre> get distinctGenres =>
      items.whereType<Book>().map((b) => b.genre).toSet();

  List<String> get displayList {
    final books = items.whereType<Book>();
    final hasIncompleteBooks = books.any((b) => b.pages == 0);

    return [
      '=== CATALOGUE ===',
      for (final book in books) '${book.title} (${book.year})',
      ...distinctAuthorNames.map((name) => 'Author: $name'),
      if (hasIncompleteBooks) '(incomplete data)',
    ];
  }
}