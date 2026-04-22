import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/scan_history.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('halal_scanner.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE scans(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        barcode TEXT,
        productName TEXT,
        halalStatus TEXT,
        ingredients TEXT,
        scannedAt TEXT
      )
    ''');
  }

  Future<void> insertScan(ScanHistory scan) async {
    final db = await database;
    await db.insert('scans', scan.toMap());
  }

  Future<List<ScanHistory>> getAllScans() async {
    final db = await database;
    final result = await db.query('scans', orderBy: 'scannedAt DESC');
    return result.map((map) => ScanHistory.fromMap(map)).toList();
  }

  Future<void> clearHistory() async {
    final db = await database;
    await db.delete('scans');
  }
}