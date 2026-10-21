import 'package:hello/week02/data.dart';
import 'package:hello/week02/models.dart';
import 'package:hello/week02/catalogue.dart';
import 'package:hello/week02/shelf_state.dart';

void main() {
  final library = Library();
  library.open();

  final List<Book> parsedBooks = rawBooks.map((json) => Book.fromJson(json)).toList();
  for (final book in parsedBooks) {
    library.add(book);
  }

  print('--- Level 1 & 2: Models & Describe ---');
  for (final book in parsedBooks) {
    print('${book.describe()} | Is Long: ${book.isLong} | Is Old: ${book.isOld}');
    print(book.borrowLabel());
  }

  print('\n--- Level 3: Null Safety Checks ---');
  print('Country of "Clean Code": ${library.countryOf('Clean Code')}');
  print('Country of "Design Patterns": ${library.countryOf('Design Patterns')}');
  print('Country of "Nonexistent": ${library.countryOf('Nonexistent')}');
  print(library.report);

  print('\n--- Level 4: Collections Queries ---');
  print('Every Title: ${library.everyTitle.toList()}');
  print('Books > 2010: ${library.booksPublishedAfter2010.map((b) => b.title).toList()}');
  print('Average Page Count: ${library.averagePageCount.toStringAsFixed(1)}');
  print('Author Book Count: ${library.authorBookCount}');
  print('Distinct Authors: ${library.distinctAuthorNames}');
  print('Distinct Genres: ${library.distinctGenres}');

  print('\n--- Display List ---');
  for (final line in library.displayList) {
    print(line);
  }

  print('\n--- Level 5: Dart 3 Features ---');
  final stats = statsOf(parsedBooks);
  print('Stats Record -> Count: ${stats.count}, Avg Pages: ${stats.avgPages.toStringAsFixed(1)}');

  final states = <ShelfState>[
    Empty(),
    Ready(parsedBooks),
    Broken('Physical structural damage'),
  ];

  for (final state in states) {
    print(describeShelf(state));
  }
}