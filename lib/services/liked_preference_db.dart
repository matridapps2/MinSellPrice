import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/**
 * LikedPreferencesDB - A dedicated database for managing liked/favorite products
 * 
 * This class handles all operations related to user's favorite products including:
 * - Saving products when user likes them
 * - Removing products when user unlikes them  
 * - Checking if a product is already liked
 * - Getting all liked products for display
 * 
 * Database Structure:
 * Table: liked_products
 * Columns:
 * - id: Auto-increment primary key
 * - product_id: Product ID from API
 * - vendor_product_id: Unique vendor product ID (from API response)
 * - product_name: Name of the product
 * - product_image: URL of product image
 * - brand_name: Brand/manufacturer name
 * - product_mpn: Product MPN (Model Part Number)
 * - product_price: Price as string
 * - is_liked: 1 if liked, 0 if not (always 1 in this table)
 * - created_at: When the product was added to favorites
 */
class LikedPreferencesDB {
  // Static database instance - shared across the entire app
  static Database? _database;

  // Table name for storing liked products
  static const String _tableName = 'liked_products';

  /**
   * Getter for database instance
   * 
   * This ensures we only create one database connection and reuse it
   * If database doesn't exist, it initializes a new one
   * 
   * Returns: Database instance
   */
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /**
   * Initialize database
   * 
   * Creates the database file and sets up the table structure
   * Database file location: app_documents/liked_preference.db
   * 
   * Returns: Configured Database instance
   */
  static Future<Database> _initDatabase() async {
    // Get the path where database should be stored
    String path = join(await getDatabasesPath(), 'liked_preference.db');

    // Open/create database with version 1
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTable, // Called when database is created for first time
    );
  }

  /**
   * Create table for liked products
   * 
   * This method is called automatically when database is created for the first time
   * Creates the 'liked_products' table with all necessary columns
   * 
   * @param db Database instance
   * @param version Database version number
   */
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
        is_liked INTEGER NOT NULL DEFAULT 1,      -- Always 1 in this table (liked status)
        created_at TEXT NOT NULL,                 -- When user liked this product
        UNIQUE(vendor_product_id)                 -- Prevent duplicate entries
      )
    ''');
  }

  /**
   * Add a product to liked/favorites list
   * 
   * Saves all product information when user taps the heart/like button
   * Uses INSERT OR REPLACE to handle duplicates gracefully
   * 
   * @param productId Product ID from API response
   * @param vendorProductId Unique vendor product ID (like 7659 from API)
   * @param productName Display name of the product
   * @param productImage URL of product image
   * @param brandName Brand/manufacturer name
   * @param productMpn Model Part Number
   * @param productPrice Price as string
   */
  static Future<void> addLikedProduct({
    required int productId,
    required int vendorProductId,
    required String productName,
    required String productImage,
    required String brandName,
    required String productMpn,
    required String productPrice,
  }) async {
    final db = await database;

    // Insert product into liked_products table
    // INSERT OR REPLACE ensures no duplicates based on vendor_product_id
    await db.execute('''
      INSERT OR REPLACE INTO $_tableName 
      (product_id, vendor_product_id, product_name, product_image, brand_name, product_mpn, product_price, is_liked, created_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, 1, ?)
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

  /**
   * Remove a product from liked/favorites list
   * 
   * Deletes the product when user unlikes it (taps heart again)
   * Uses vendor_product_id to identify which product to remove
   * 
   * @param vendorProductId Unique vendor product ID to remove
   */
  static Future<void> removeLikedProduct({required int vendorProductId}) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'vendor_product_id = ?',
      whereArgs: [vendorProductId],
    );
  }

  /**
   * Get all liked products for display in favorites screen
   * 
   * Returns all products that user has liked, ordered by most recent first
   * Used by the Liked Products screen to show user's favorites
   * 
   * Returns: List of liked products as Map objects
   * Each Map contains: product_id, vendor_product_id, product_name, 
   * product_image, brand_name, product_mpn, product_price, is_liked, created_at
   */
  static Future<List<Map<String, dynamic>>> getAllLikedProducts() async {
    final db = await database;
    return await db.query(
      _tableName,
      where: 'is_liked = ?',
      whereArgs: [1], // Only get liked products (should be all in this table)
      orderBy: 'created_at DESC', // Most recently liked first
    );
  }

  /**
   * Check if a specific product is already liked
   * 
   * Used to determine if heart icon should be filled or empty
   * Called when loading product details to show correct like status
   * 
   * @param vendorProductId Unique vendor product ID to check
   * @return true if product is liked, false if not
   */
  static Future<bool> isProductLiked({required int vendorProductId}) async {
    final db = await database;
    final result = await db.query(
      _tableName,
      where: 'vendor_product_id = ? AND is_liked = ?',
      whereArgs: [vendorProductId, 1],
    );
    return result.isNotEmpty; // If we found a record, it's liked
  }

  /**
   * Toggle like status of a product (like/unlike)
   * 
   * This is the main method called when user taps the heart button
   * If product is liked -> removes it (unlike)
   * If product is not liked -> adds it (like)
   * 
   * @param productId Product ID from API
   * @param vendorProductId Unique vendor product ID
   * @param productName Product display name
   * @param productImage Product image URL
   * @param brandName Brand name
   * @param productMpn Model Part Number
   * @param productPrice Product price
   * @return true if now liked, false if now unliked
   */
  static Future<bool> toggleLikeProduct({
    required int productId,
    required int vendorProductId,
    required String productName,
    required String productImage,
    required String brandName,
    required String productMpn,
    required String productPrice,
  }) async {
    // Check current like status
    final isLiked = await isProductLiked(vendorProductId: vendorProductId);

    if (isLiked) {
      // Product is currently liked -> remove it (unlike)
      await removeLikedProduct(vendorProductId: vendorProductId);
      return false; // Now not liked
    } else {
      // Product is not liked -> add it (like)
      await addLikedProduct(
        productId: productId,
        vendorProductId: vendorProductId,
        productName: productName,
        productImage: productImage,
        brandName: brandName,
        productMpn: productMpn,
        productPrice: productPrice,
      );
      return true; // Now liked
    }
  }

  /**
   * Get total count of liked products
   * 
   * Useful for showing badges or counts in UI
   * Could be used for "You have 5 favorite products" type displays
   * 
   * @return Number of products in favorites
   */
  static Future<int> getLikedProductsCount() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName WHERE is_liked = 1');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /**
   * Clear all liked products
   * 
   * Removes all products from favorites
   * Could be used for "Clear all favorites" functionality
   * or when user logs out and wants to reset
   */
  static Future<void> clearAllLikedProducts() async {
    final db = await database;
    await db.delete(_tableName);
  }
}
