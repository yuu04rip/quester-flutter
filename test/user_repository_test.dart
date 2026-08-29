// test/user_repository_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:Quester/data/dao/user_dao.dart';
import 'package:Quester/data/models/user.dart';
import 'package:Quester/repository/user_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Future<UserRepository> createRepository() async {
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

    return UserRepository(
      userDao: UserDao(db),
      ownedCosmeticDao: null,
    );
  }

  test('XP stops increasing after reaching max level', () async {
    final userRepository = await createRepository();
    final userDao = userRepository.userDao;
    final maxXp = UserRepository.absoluteMaxXp;

    final user = User(
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

  test('Level 50 is reached at 63750 XP, not 63700', () async {
    final repo = await createRepository();
    
    // 63700 deve essere ancora livello 49
    expect(repo.calculateLevelFromXp(63700), equals(49));
    
    // 63750 deve essere livello 50
    expect(repo.calculateLevelFromXp(63750), equals(50));
    expect(repo.calculateLevelFromXp(64000), equals(50));
  });

  test('Multiple level-ups reward coins correctly with new formula', () async {
    final userRepository = await createRepository();
    final userDao = userRepository.userDao;

    final user = User(
      username: 'newbie',
      passwordHash: 'hash',
      xpTotale: 0,
      livello: 1,
      coins: 0,
    );

    final userId = await userDao.insertUser(user);
    
    // Con xpBase=100 e xpIncrement=50:
    // Livello 1 -> 2: 100 XP (Total 100) -> Reward 3
    // Livello 2 -> 3: 150 XP (Total 250) -> Reward 3
    // Diamo 300 XP.
    await userRepository.addXp(userId, 300);

    final updatedUser = await userDao.getUserById(userId);
    expect(updatedUser!.livello, equals(3));
    expect(updatedUser.coins, equals(6));
  });

  test('Self-healing corrects level if mismatched with XP', () async {
    final userRepository = await createRepository();
    final userDao = userRepository.userDao;

    // Utente con XP da livello 3 ma segnato come livello 1
    final user = User(
      username: 'broken',
      passwordHash: 'hash',
      xpTotale: 300,
      livello: 1,
      coins: 0,
    );

    final userId = await userDao.insertUser(user);
    
    // Il metodo getUserById dovrebbe correggere il livello
    final correctedUser = await userRepository.getUserById(userId);
    
    expect(correctedUser!.livello, equals(3));
    
    // Verifica che sia stato aggiornato nel DB
    final dbUser = await userDao.getUserById(userId);
    expect(dbUser!.livello, equals(3));
  });
}
