// lib/data/dao/user_dao.dart

import 'package:sqflite/sqflite.dart';
import '../models/user.dart';

class UserDao {
  final Database db;

  UserDao(this.db);

  // Insert utente
  Future<int> insertUser(User user) async {
    final map = user.toMap();
    map.remove('id');  // ✅ Rimuovi id — il DB lo auto-genera!

    return await db.insert(
      'users',
      map,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // Primo utente
  Future<User?> getUser() async {
    final result = await db.query('users', limit: 1);
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  // Utente per ID
  Future<User?> getUserById(int userId) async {
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  // Utente per username
  Future<User?> getUserByUsername(String username) async {
    final result = await db.query(
      'users',
      where: 'username = ? COLLATE NOCASE',
      whereArgs: [username],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  // Utente per email
  Future<User?> getUserByEmail(String email) async {
    final result = await db.query(
      'users',
      where: 'email = ? COLLATE NOCASE',
      whereArgs: [email],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  // Utente per identità (username o email)
  Future<User?> getUserByIdentity(String identity) async {
    final result = await db.query(
      'users',
      where: 'username = ? COLLATE NOCASE OR email = ? COLLATE NOCASE',
      whereArgs: [identity, identity],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  // Update utente
  Future<void> updateUser(User user) async {
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Delete utente per ID
  Future<void> deleteUser(int userId) async {
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Delete tutti gli utenti
  Future<void> deleteAllUsers() async {
    await db.delete('users');
  }
}