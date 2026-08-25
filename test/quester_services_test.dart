import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:quester_flutter/data/dao/user_dao.dart';
import 'package:quester_flutter/data/models/user.dart';
import 'package:quester_flutter/repository/user_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Future<UserRepository> _createRepository() async {
    final db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            username TEXT NOT NULL UNIQUE,
            email TEXT UNIQUE,
            passwordHash TEXT NOT NULL,
            xpTotale INTEGER NOT NULL DEFAULT 0,
            livello INTEGER NOT NULL DEFAULT 1,
            coins INTEGER NOT NULL DEFAULT 0,
            equippedHat TEXT NOT NULL DEFAULT 'NONE',
            equippedWeapon TEXT NOT NULL DEFAULT 'NONE',
            equippedFrame TEXT NOT NULL DEFAULT 'NONE'
          )
        ''');
      },
    );

    return UserRepository(userDao: UserDao(db));
  }

  test('XP stops increasing after reaching max level', () async {
    final userRepository = await _createRepository();
    final userDao = userRepository.userDao;
    final maxXp = userRepository.getTotalXpRequiredForLevel(
      UserRepository.maxLevel,
    );

    final user = User(
      id: 1,
      username: 'maxplayer',
      passwordHash: 'hash',
      xpTotale: maxXp,
      livello: UserRepository.maxLevel,
      coins: 0,
    );

    final userId = await userDao.insertUser(user);
    await userRepository.addXp(userId, 250);

    final updatedUser = await userDao.getUserById(userId);
    expect(updatedUser, isNotNull);
    expect(updatedUser!.xpTotale, equals(maxXp));
    expect(updatedUser.livello, equals(UserRepository.maxLevel));
  });

  test('XP cap is calculated correctly for the final level', () async {
    final repo = await _createRepository();
    final maxXp = repo.getTotalXpRequiredForLevel(UserRepository.maxLevel);

    expect(repo.calculateLevelFromXp(maxXp), equals(UserRepository.maxLevel));
    expect(
      repo.calculateLevelFromXp(maxXp + 1000),
      equals(UserRepository.maxLevel),
    );
  });
}