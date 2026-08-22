// lib/data/dao/shop_dao.dart

import 'package:sqflite/sqflite.dart';
import '../models/shop_item.dart';

class ShopDao {
  final Database db;

  ShopDao(this.db);

  // Tutti gli item ordinati per prezzo
  Future<List<ShopItem>> getAllItems() async {
    final result = await db.query(
      'shop_items',
      orderBy: 'price ASC',
    );
    return result.map((map) => ShopItem.fromMap(map)).toList();
  }

  // Elimina tutti gli item
  Future<void> deleteAllItems() async {
    await db.delete('shop_items');
  }

  // Item per ID
  Future<ShopItem?> getItemByItemId(String itemId) async {
    final result = await db.query(
      'shop_items',
      where: 'itemId = ?',
      whereArgs: [itemId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return ShopItem.fromMap(result.first);
  }

  // Upsert di una lista di item
  Future<void> upsertItems(List<ShopItem> items) async {
    final batch = db.batch();
    for (final item in items) {
      batch.insert(
        'shop_items',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // Insert singolo item
  Future<void> insertItem(ShopItem item) async {
    await db.insert(
      'shop_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}