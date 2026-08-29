// lib/data/dao/owned_cosmetic_dao.dart

import 'package:sqflite/sqflite.dart';
import '../models/owned_cosmetic.dart';

class OwnedCosmeticDao {
  final DatabaseExecutor db;

  OwnedCosmeticDao(this.db);

  // Insert cosmetico posseduto
  Future<int> insertOwned(OwnedCosmetic item) async {
    return await db.insert(
      'owned_cosmetics',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // Verifica se posseduto
  Future<bool> isOwned(int userId, String itemId) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM owned_cosmetics WHERE userId = ? AND itemId = ?',
      [userId, itemId],
    );
    return (Sqflite.firstIntValue(result) ?? 0) > 0;
  }

  // Cosmetici posseduti dall'utente
  Future<List<OwnedCosmetic>> getOwnedByUser(int userId) async {
    final result = await db.query(
      'owned_cosmetics',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return result.map((map) => OwnedCosmetic.fromMap(map)).toList();
  }

  // Elimina tutti i cosmetici di un utente
  Future<void> deleteAllForUser(int userId) async {
    await db.delete(
      'owned_cosmetics',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  // Elimina un cosmetico specifico
  Future<void> deleteOwned(int userId, String itemId) async {
    await db.delete(
      'owned_cosmetics',
      where: 'userId = ? AND itemId = ?',
      whereArgs: [userId, itemId],
    );
  }
}