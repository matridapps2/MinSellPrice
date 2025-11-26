import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// ComparisonDB - A dedicated database for managing product comparisons
/// 
/// This class handles all operations related to product comparison including:
/// - Adding products to comparison list (max 4 products)
/// - Removing products from comparison
/// - Getting all products in comparison
/// - Checking if a product is already in comparison
/// - Clearing all comparisons
/// 
/// Database Structure:
/// Table: comparison_products
/// Columns:
/// - id: Auto-increment primary key
/// - product_id: Product ID from API
/// - vendor_product_id: Unique vendor product ID (from API response)
/// - product_name: Name of the product
/// - product_image: URL of product image
/// - brand_name: Brand/manufacturer name
/// - product_mpn: Product MPN (Model Part Number)
/// - product_price: Price as string
/// - added_at: When the product was added to comparison
class ComparisonDB {
  // Static database instance - shared across the entire app
  static Database? _database;

  // Table name for storing comparison products
  static const String _tableName = 'comparison_products';

  // Maximum products allowed in comparison
  static const int maxComparisonProducts = 4;

  /// Getter for database instance
  /// 
  /// This ensures we only create one database connection and reuse it
  /// If database doesn't exist, it initializes a new one
  /// 
  /// Returns: Database instance
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  /// 
  /// Creates the database file and sets up the table structure
  /// Database file location: app_documents/comparison.db
  /// 
  /// Returns: Configured Database instance
  static Future<Database> _initDatabase() async {
    // Get the path where database should be stored
    String path = join(await getDatabasesPath(), 'comparison.db');

    // Open/create database with version 1
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTable, // Called when database is created for first time
    );
  }

  /// Create table for comparison products
  /// 
  /// This method is called automatically when database is created for the first time
  /// Creates the 'comparison_products' table with all necessary columns
  /// 
  /// @param db Database instance
  /// @param version Database version number
  static Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,     -- Auto-increment ID
        product_id INTEGER NOT NULL,              -- Product ID from API
        vendor_product_id INTEGER NOT NULL,       -- Unique vendor product ID (from API like 7659)
        product_name TEXT NOT NULL,               -- Product name for display
        product_image TEXT,                       -- Product image URL (can be null)
        brand_name TEXT NOT NULL,                 -- Brand name (Delta, Weber, etc.)
        product_mpn TEXT NOT NULL,                -- Model Part Number (UG600, etc.)
        product_price TEXT,                       -- Price as string (26.65, etc.)
        added_at TEXT NOT NULL,                   -- When user added this product to comparison
        UNIQUE(vendor_product_id)                 -- Prevent duplicate entries
      )
    ''');
  }

  /// Add a product to comparison list
  /// 
  /// Saves product information when user taps the compare button
  /// Checks maximum limit before adding
  /// 
  /// @param productId Product ID from API response
  /// @param vendorProductId Unique vendor product ID (like 7659 from API)
  /// @param productName Display name of the product
  /// @param productImage URL of product image
  /// @param brandName Brand/manufacturer name
  /// @param productMpn Model Part Number
  /// @param productPrice Price as string
  /// @throws Exception if maximum comparison limit reached
  static Future<void> addToComparison({
    required int productId,
    required int vendorProductId,
    required String productName,
    required String productImage,
    required String brandName,
    required String productMpn,
    required String productPrice,
  }) async {
    final db = await database;

    // Check if maximum limit reached
    final currentCount = await getComparisonCount();
    if (currentCount >= maxComparisonProducts) {
      throw Exception(
          'Maximum $maxComparisonProducts products can be compared at once');
    }

    // Check if product already in comparison
    final isAlreadyAdded =
        await isInComparison(vendorProductId: vendorProductId);
    if (isAlreadyAdded) {
      throw Exception('Product is already in comparison');
    }

    // Insert product into comparison_products table
    await db.execute('''
      INSERT INTO $_tableName 
      (product_id, vendor_product_id, product_name, product_image, brand_name, product_mpn, product_price, added_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
      productId,
      vendorProductId,
      productName,
      productImage,
      brandName,
      productMpn,
      productPrice,
      DateTime.now().toIso8601String(), // Current timestamp
    ]);
  }

  /// Remove a product from comparison list
  /// 
  /// Deletes the product when user removes it from comparison
  /// Uses vendor_product_id to identify which product to remove
  /// 
  /// @param vendorProductId Unique vendor product ID to remove
  static Future<void> removeFromComparison(
      {required int vendorProductId}) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'vendor_product_id = ?',
      whereArgs: [vendorProductId],
    );
  }

  /// Get all products in comparison for display in comparison screen
  /// 
  /// Returns all products that user has added to comparison, ordered by most recent first
  /// Used by the Comparison screen to show side-by-side comparison
  /// 
  /// Returns: List of comparison products as Map objects
  /// Each Map contains: product_id, vendor_product_id, product_name, 
  /// product_image, brand_name, product_mpn, product_price, added_at
  static Future<List<Map<String, dynamic>>> getAllComparisonProducts() async {
    final db = await database;
    return await db.query(
      _tableName,
      orderBy: 'added_at ASC', // First added appears first in comparison
    );
  }

  /// Check if a specific product is already in comparison
  /// 
  /// Used to determine if compare button should show "Add to Compare" or "Remove from Compare"
  /// Called when loading product details to show correct comparison status
  /// 
  /// @param vendorProductId Unique vendor product ID to check
  /// @return true if product is in comparison, false if not
  static Future<bool> isInComparison({required int vendorProductId}) async {
    final db = await database;
    final result = await db.query(
      _tableName,
      where: 'vendor_product_id = ?',
      whereArgs: [vendorProductId],
    );
    return result.isNotEmpty; // If we found a record, it's in comparison
  }

  /// Toggle comparison status of a product (add/remove from comparison)
  /// 
  /// This is the main method called when user taps the compare button
  /// If product is in comparison -> removes it
  /// If product is not in comparison -> adds it (if under limit)
  /// 
  /// @param productId Product ID from API
  /// @param vendorProductId Unique vendor product ID
  /// @param productName Product display name
  /// @param productImage Product image URL
  /// @param brandName Brand name
  /// @param productMpn Model Part Number
  /// @param productPrice Product price
  /// @return true if now in comparison, false if removed from comparison
  /// @throws Exception if maximum limit reached when trying to add
  static Future<bool> toggleComparison({
    required int productId,
    required int vendorProductId,
    required String productName,
    required String productImage,
    required String brandName,
    required String productMpn,
    required String productPrice,
  }) async {
    // Check current comparison status
    final isInComparisonList =
        await isInComparison(vendorProductId: vendorProductId);

    if (isInComparisonList) {
      // Product is currently in comparison -> remove it
      await removeFromComparison(vendorProductId: vendorProductId);
      return false; // Now not in comparison
    } else {
      // Product is not in comparison -> add it (may throw exception if limit reached)
      await addToComparison(
        productId: productId,
        vendorProductId: vendorProductId,
        productName: productName,
        productImage: productImage,
        brandName: brandName,
        productMpn: productMpn,
        productPrice: productPrice,
      );
      return true; // Now in comparison
    }
  }

  /// Get total count of products in comparison
  /// 
  /// Useful for showing count in UI and checking limits
  /// Used for "Compare (3)" type displays and limiting additions
  /// 
  /// @return Number of products in comparison
  static Future<int> getComparisonCount() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Clear all products from comparison
  /// 
  /// Removes all products from comparison list
  /// Used for "Clear All" functionality or when starting fresh comparison
  static Future<void> clearAllComparisons() async {
    final db = await database;
    await db.delete(_tableName);
  }

  /// Check if comparison list has minimum products for meaningful comparison
  /// 
  /// @return true if has 2 or more products (minimum for comparison)
  static Future<bool> hasMinimumForComparison() async {
    final count = await getComparisonCount();
    return count >= 2;
  }
}
