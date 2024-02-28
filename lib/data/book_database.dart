import 'dart:io' show Platform;

import 'package:nytimes_bestsellers/data/book.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class BookDatabase {
  Database? _database;
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      final databaseFactory = databaseFactoryFfi;
      final appDocumentsDir = await getApplicationDocumentsDirectory();
      final dbPath = join(appDocumentsDir.path, "databases", "books.db");
      final winLinuxDB = await databaseFactory.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _onCreate,
        ),
      );
      return winLinuxDB;
    } else if (Platform.isAndroid || Platform.isIOS) {
      final iOSAndroidDB = openDatabase(
        join(await getDatabasesPath(), "books.db"),
        version: 1,
        onCreate: _onCreate,
      );
      return iOSAndroidDB;
    }
    throw Exception("Unsupported platform");
  }

  Future<void> _onCreate(Database database, int version) async {
    final db = database;
    await db.execute("""CREATE TABLE IF NOT EXISTS books (
        isbn INTEGER PRIMARY KEY,
        title TEXT,
        author TEXT,
        imageUrl TEXT,
        description TEXT,
        amazonLink TEXT
      )
    """);
  }

  Future<List<Book>> getAllBooks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query("books");

    return List.generate(maps.length, (index) =>
      Book.fromDBResult(maps[index])
    );
  }

  Future<void> insertBook(Book book) async {
    final db = await database;
    db.insert(
      "books",
      book.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteBook(Book book) async {
    final db = await database;
    db.delete("books",
      where: 'isbn = ?',
      whereArgs: [book.isbn]
    );
  }
}

