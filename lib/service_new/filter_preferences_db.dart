import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class FilterPreferencesDB {
  static Database? _database;
  static const String _tableName = 'filter_preferences';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'filter_preferences.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTable,
    );
  }

  static Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        brand_name TEXT UNIQUE,
        selected_vendors TEXT,
        price_sorting INTEGER,
        min_price REAL,
        max_price REAL,
        in_stock_only INTEGER,
        on_sale_only INTEGER,
        created_at TEXT
      )
    ''');
  }

  static Future<void> saveFilterPreferences({
    required String brandName,
    required List<String> selectedVendors,
    int? priceSorting,
    required double minPrice,
    required double maxPrice,
    required bool inStockOnly,
    required bool onSaleOnly,
  }) async {
    final db = await database;

    await db.insert(
      _tableName,
      {
        'brand_name': brandName,
        'selected_vendors': jsonEncode(selectedVendors),
        'price_sorting': priceSorting,
        'min_price': minPrice,
        'max_price': maxPrice,
        'in_stock_only': inStockOnly ? 1 : 0,
        'on_sale_only': onSaleOnly ? 1 : 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Map<String, dynamic>?> getFilterPreferences(String brandName) async {
    final db = await database;

    final List<Map<String, dynamic>> results = await db.query(
      _tableName,
      where: 'brand_name = ?',
      whereArgs: [brandName],
      limit: 1,
    );

    if (results.isNotEmpty) {
      final data = results.first;
      return {
        'selectedVendors':
            List<String>.from(jsonDecode(data['selected_vendors'])),
        'priceSorting': data['price_sorting'],
        'minPrice': data['min_price'],
        'maxPrice': data['max_price'],
        'inStockOnly': data['in_stock_only'] == 1,
        'onSaleOnly': data['on_sale_only'] == 1,
      };
    }

    return null;
  }

  static Future<void> clearFilterPreferences(String brandName) async {
    final db = await database;

    await db.delete(
      _tableName,
      where: 'brand_name = ?',
      whereArgs: [brandName],
    );
  }

  static Future<List<Map<String, dynamic>>> getAllFilterPreferences() async {
    final db = await database;
    return await db.query(_tableName, orderBy: 'created_at DESC');
  }

  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
