import 'dart:async';

import 'package:minsellprice/reposotory_services/database/database_constants.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await initDatabase();
    return _database;
  }

  Future<Database> initDatabase() async {
    String path = '${await getDatabasesPath()}/$databaseName';
    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    String query = '''
      CREATE TABLE IF NOT EXISTS "$loginTable" (
        "$idKey" INTEGER PRIMARY KEY,
        "$emailKey" TEXT,
        "$nameKey" TEXT,
        "$vendor_idKey" INTEGER,
        "$vendor_nameKey" TEXT,
        "$vendor_short_nameKey" TEXT,
        "$sister_concern_vendorKey" TEXT,
        "$sister_vendor_short_nameKey" TEXT,
        "$fcm_token_key" TEXT
      );
    ''';

    await db.execute(query);
    createProductTable(db: db);
    createSearchHistoryTable(db: db);
    // await db.execute(queryProduct);
  }

  Future<void> insertLogin(Database db, Map<String, dynamic> row) async {
    /*Saving Login Data*/
    // Insert the row into the table and return the id

    await db.execute(
      '''
      INSERT INTO "$loginTable" 
      ("$idKey",
       "$emailKey",
       "$nameKey",
       "$vendor_idKey",
       "$vendor_nameKey",
       "$vendor_short_nameKey",
       "$sister_concern_vendorKey",
       "$sister_vendor_short_nameKey",
       "$fcm_token_key"
       ) 
      VALUES 
      (
      ${row[idKey]}, 
      "${row[emailKey]}",
      "${row[nameKey]}",
      ${row[vendor_idKey]},
      "${row[vendor_nameKey]}",
      "${row[vendor_short_nameKey]}",
      "${row[sister_concern_vendorKey]}",
      "${row[sister_vendor_short_nameKey]}",
      "${row[fcm_token_key]}"
      )
      
      ON CONFLICT ("$idKey") DO UPDATE SET
      "$emailKey" = excluded."$emailKey",
      "$nameKey" = excluded."$nameKey",
      "$vendor_idKey" = excluded."$vendor_idKey",
      "$vendor_nameKey" = excluded."$vendor_nameKey",
      "$vendor_short_nameKey" = excluded."$vendor_short_nameKey",
      "$sister_concern_vendorKey" = excluded."$sister_concern_vendorKey",
      "$sister_vendor_short_nameKey" = excluded."$sister_vendor_short_nameKey",
      "$fcm_token_key" = excluded."$fcm_token_key"
      
      ''',
    );

    // Query data from the database using a raw SQL query
    List<Map> result = await db.rawQuery('SELECT * FROM "$loginTable"');

    // Print the result
    print(result);
  }

  Future<bool> isUserLoggedIn({required Database db}) async {
    // Query data from the database using a raw SQL query
    List<Map> result = await db.rawQuery('SELECT * FROM "$loginTable"');

    return result.isNotEmpty;
  }

  Future<bool> columnExists(
      {required Database db,
      required String tableName,
      required String columnName}) async {
    final result = await db.rawQuery('PRAGMA table_info($tableName)');
    final columnIndex = result.indexWhere((row) => row['name'] == columnName);
    return columnIndex != -1;
  }

  Future<Map<String, dynamic>> getUserInformation(
      {required Database db}) async {
    List<Map<String, dynamic>> result1 = await db.rawQuery('''
        SELECT * FROM "$loginTable"
        ''');
    print(result1);
    List<Map<String, dynamic>> result = await db.query(loginTable);

    return result[0];
  }

  Future<void> logout({required Database db}) async {
    await db.rawDelete('''
    DELETE FROM "$loginTable"
        ''');
    List<Map<String, dynamic>> result = await db.rawQuery('''
        SELECT * FROM "$loginTable"
        ''');
  }

  Future<void> addAndUpdateProduct({
    required Database db,
    required int vendorId,
    required int productSku,
    required int isLiked,
    required int isNotified,
    required String productData,
  }) async {
    String query = '''
  INSERT OR REPLACE INTO $productTable ("$uniqueId", "$productSKU", "$isLikedKey", "$isNotifiedKey", "$productDataKey")
  VALUES (
    $vendorId,  
    $productSku,    
    $isLiked,       
    $isNotified,
    '$productData'
  );    
  ''';

    await db.execute(query);
  }

  Future<void> createProductTable({
    required Database db,
  }) async {
    showAllProducts(db: db);
    String queryProduct = '''
    CREATE TABLE IF NOT EXISTS "$productTable" (
      "$uniqueId" INTEGER PRIMARY KEY,
      "$productSKU" INTEGER,
      "$isLikedKey" INTEGER,
      "$isNotifiedKey" INTEGER,
      $productDataKey TEXT
    );
  ''';

    await db.execute(queryProduct);

    // // Check if the column already exists
    // List<Map> columns = await db.rawQuery('PRAGMA table_info($productTable)');
    // bool columnExists =
    //     columns.indexWhere((Map column) => column['name'] == productDataKey) !=
    //         -1;
    //
    // if (!columnExists) {
    //   // Column does not exist, so we add it
    //   await db
    //       .execute('ALTER TABLE $productTable ADD COLUMN $productDataKey TEXT');
    // }
  }

  Future<void> showAllProducts({required Database db}) async {
    String sqlQuery = '''
        
        SELECT * FROM $productTable;
        
        ''';

    final result = await db.rawQuery(sqlQuery);
  }

  Future<List<Map<String, dynamic>>> getData({required Database db}) async {
    // Replace 'tableName' with your actual table name
    final List<Map<String, dynamic>> maps =
        await db.query(productTable, orderBy: '$uniqueId DESC');

    return maps;
  }

  Future<void> createSearchHistoryTable({
    required Database db,
  }) async {
    showAllProducts(db: db);
    String queryProduct = '''
    CREATE TABLE IF NOT EXISTS "$historyTable" (
      "$vendor_idKey" INTEGER ,
      "$afSkuKey" TEXT,
      "$hpSkuKey" TEXT,
      "$productMPNKey" TEXT,
      "$productNameKey" TEXT,
      $listId INTEGER
     
    );
  ''';
    // List<Map> columns = await db.rawQuery('PRAGMA table_info($historyTable)');
    // bool columnExists =
    //     columns.indexWhere((Map column) => column['name'] == listId) !=
    //         -1;
    //
    // if (!columnExists) {
    //   // Column does not exist, so we add it
    //   await db
    //       .execute('ALTER TABLE $historyTable ADD COLUMN $listId INTEGER');
    // }

    await db.execute(queryProduct);
  }

  Future<void> addSearchHistory({
    required Database db,
    required int vendorId,
    required int id,
    required String afSku,
    required String hpSku,
    required String productMpn,
    required String productName,
  }) async {
    // First, try to update the record
    String updateQuery = '''
      UPDATE $historyTable
      SET "$vendor_idKey" = $vendorId,
          "$afSkuKey" = "$afSku",
          "$hpSkuKey" = "$hpSku",
          "$productMPNKey" = "$productMpn",
          "$productNameKey" = "$productName",
          "$listId" = $id
      WHERE "$vendor_idKey" = $vendorId
        AND "$afSkuKey" = "$afSku"
        AND "$hpSkuKey" = "$hpSku"
        AND "$productMPNKey" = "$productMpn"
        AND "$productNameKey" = "$productName"
    ''';

    int rowsAffected = await db.rawUpdate(updateQuery);

    // If the update didn't affect any rows, then the record doesn't exist and we should insert it
    if (rowsAffected == 0) {
      String insertQuery = '''
        INSERT INTO $historyTable ("$vendor_idKey", "$afSkuKey", "$hpSkuKey", "$productMPNKey", "$productNameKey","$listId")
        VALUES (
          $vendorId,  
          "$afSku",    
          "$hpSku",       
          "$productMpn",
          "$productName",
          $id
        )
      ''';

      await db.execute(insertQuery);
    }
  }

  Future<List<Map<String, dynamic>>> getHistoryData(
      {required Database db}) async {
    // Replace 'tableName' with your actual table name
    final List<Map<String, dynamic>> maps =
        await db.query(historyTable, orderBy: "$listId DESC", limit: 50);

    return maps ?? [];
  }

  Future<void> removeSearchHistory(
      {required Database db, required int listID}) async {
    String deleteQuery = '''
    
    DELETE FROM $historyTable WHERE (
    $listId=$listID
    )
    ;
        
    
    ''';

    await db.rawDelete(deleteQuery);
  }
}
