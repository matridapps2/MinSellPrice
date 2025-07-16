import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DashboardCategoriesDB {
  static Database? _database;
  static const String tableName = 'dashboard_categories';

  // Table columns
  static const String columnId = 'id';
  static const String columnBrandName = 'brand_name';
  static const String columnBrandKey = 'brand_key';
  static const String columnBrandId = 'brand_id';
  static const String columnCategory = 'category';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  // Get database instance
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize database
  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'dashboard_categories.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Create table
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnBrandName TEXT NOT NULL,
        $columnBrandKey TEXT NOT NULL,
        $columnBrandId INTEGER NOT NULL,
        $columnCategory TEXT NOT NULL,
        $columnCreatedAt TEXT NOT NULL,
        $columnUpdatedAt TEXT NOT NULL
      )
    ''');
  }

  // Insert single category
  static Future<int> insertCategory(Map<String, dynamic> category) async {
    final db = await database;
    category[columnCreatedAt] = DateTime.now().toIso8601String();
    category[columnUpdatedAt] = DateTime.now().toIso8601String();
    return await db.insert(tableName, category);
  }

  // Insert multiple categories
  static Future<void> insertCategories(
      List<Map<String, dynamic>> categories, String categoryType) async {
    final db = await database;
    final batch = db.batch();

    for (var category in categories) {
      category[columnCategory] = categoryType;
      category[columnCreatedAt] = DateTime.now().toIso8601String();
      category[columnUpdatedAt] = DateTime.now().toIso8601String();
      batch.insert(tableName, category);
    }

    await batch.commit(noResult: true);
  }

  // Get all categories
  static Future<List<Map<String, dynamic>>> getAllCategories() async {
    final db = await database;
    return await db.query(tableName,
        orderBy: '$columnCategory ASC, $columnBrandName ASC');
  }

  // Get categories by type
  static Future<List<Map<String, dynamic>>> getCategoriesByType(
      String categoryType) async {
    final db = await database;
    return await db.query(
      tableName,
      where: '$columnCategory = ?',
      whereArgs: [categoryType],
      orderBy: '$columnBrandName ASC',
    );
  }

  static Future<List<Map<String, dynamic>>> searchCategoriesByName(
      String searchQuery) async {
    final db = await database;
    return await db.query(
      tableName,
      where: '$columnBrandName LIKE ?',
      whereArgs: ['%$searchQuery%'],
      orderBy: '$columnBrandName ASC',
    );
  }

  // Get category by brand ID
  static Future<Map<String, dynamic>?> getCategoryByBrandId(int brandId) async {
    final db = await database;
    final results = await db.query(
      tableName,
      where: '$columnBrandId = ?',
      whereArgs: [brandId],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Update category
  static Future<int> updateCategory(Map<String, dynamic> category) async {
    final db = await database;
    category[columnUpdatedAt] = DateTime.now().toIso8601String();
    return await db.update(
      tableName,
      category,
      where: '$columnBrandId = ?',
      whereArgs: [category[columnBrandId]],
    );
  }

  // Delete category by brand ID
  static Future<int> deleteCategoryByBrandId(int brandId) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: '$columnBrandId = ?',
      whereArgs: [brandId],
    );
  }

  // Delete all categories
  static Future<int> deleteAllCategories() async {
    final db = await database;
    return await db.delete(tableName);
  }

  // Delete categories by type
  static Future<int> deleteCategoriesByType(String categoryType) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: '$columnCategory = ?',
      whereArgs: [categoryType],
    );
  }

  // Check if category exists
  static Future<bool> categoryExists(int brandId) async {
    final db = await database;
    final results = await db.query(
      tableName,
      where: '$columnBrandId = ?',
      whereArgs: [brandId],
      limit: 1,
    );
    return results.isNotEmpty;
  }

  // Get total count
  static Future<int> getTotalCount() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get count by category type
  static Future<int> getCountByType(String categoryType) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE $columnCategory = ?',
      [categoryType],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Refresh categories data (delete old and insert new)
  static Future<void> refreshCategoriesData(
      Map<String, List<dynamic>> categoriesData) async {
    final db = await database;
    await db.transaction((txn) async {
      // Delete existing data
      await txn.delete(tableName);

      // Insert new data
      for (String categoryType in categoriesData.keys) {
        final categories = categoriesData[categoryType] ?? [];
        for (var category in categories) {
          if (category is Map<String, dynamic>) {
            category[columnCategory] = categoryType;
            category[columnCreatedAt] = DateTime.now().toIso8601String();
            category[columnUpdatedAt] = DateTime.now().toIso8601String();
            await txn.insert(tableName, category);
          }
        }
      }
    });
  }

  // Close database
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
