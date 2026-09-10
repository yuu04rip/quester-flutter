// lib/data/database/database_provider.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'app_database.dart';

/// Singleton che crea una sola istanza del database per tutta l'app.
class DatabaseProvider {
  static final DatabaseProvider _instance = DatabaseProvider._internal();
  static DatabaseProvider get instance => _instance;

  DatabaseProvider._internal();

  AppDatabase? _appDatabase;

  /// Ottiene l'istanza del database.
  Future<AppDatabase> getDatabase() async {
    if (_appDatabase != null) {
      return _appDatabase!;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppDatabase.dbName);

    final db = await openDatabase(
      path,
      version: AppDatabase.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // <-- Aggiunto per gestire i vecchi backup
    );

    _appDatabase = AppDatabase(db);
    return _appDatabase!;
  }

  /// Creazione iniziale del database con lo schema completo.
  Future<void> _onCreate(Database db, int version) async {
    // Tabella users
    await db.execute('''
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
        equippedFrame TEXT NOT NULL DEFAULT 'NONE',
        updatedAt INTEGER DEFAULT 0
      )
    ''');

    // Tabella missions
    await db.execute('''
      CREATE TABLE missions (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        type TEXT NOT NULL,
        dueDate TEXT,
        xpReward INTEGER NOT NULL DEFAULT 0,
        completed INTEGER NOT NULL DEFAULT 0,
        xpAwarded INTEGER NOT NULL DEFAULT 0,
        redeemed INTEGER NOT NULL DEFAULT 0,
        createdAt INTEGER NOT NULL,
        completedAt INTEGER,
        verificationLevel TEXT NOT NULL DEFAULT 'AUTO',
        isPinned INTEGER NOT NULL DEFAULT 0,
        updatedAt INTEGER DEFAULT 0,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Tabella subtasks
    await db.execute('''
      CREATE TABLE subtasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        missionId INTEGER NOT NULL,
        text TEXT NOT NULL,
        done INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (missionId) REFERENCES missions (id) ON DELETE CASCADE
      )
    ''');

    // Tabella shop_items
    await db.execute('''
      CREATE TABLE shop_items (
        itemId TEXT PRIMARY KEY NOT NULL,
        name TEXT NOT NULL,
        price INTEGER NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        iconName TEXT NOT NULL DEFAULT 'shopping_cart',
        iconScale REAL NOT NULL DEFAULT 1.0
      )
    ''');

    // Tabella owned_cosmetics
    await db.execute('''
      CREATE TABLE owned_cosmetics (
        userId INTEGER NOT NULL,
        itemId TEXT NOT NULL,
        PRIMARY KEY (userId, itemId),
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Indici per performance
    await db.execute('''
      CREATE INDEX idx_missions_userId ON missions(userId)
    ''');

    await db.execute('''
      CREATE INDEX idx_subtasks_missionId ON subtasks(missionId)
    ''');

    await db.execute('''
      CREATE INDEX idx_users_username ON users(username)
    ''');

    await db.execute('''
      CREATE INDEX idx_users_email ON users(email)
    ''');
  }

  /// Migrazione professionale
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Già gestita nella versione precedente ma aggiungiamo per sicurezza se mancante
      try { await db.execute('ALTER TABLE missions ADD COLUMN isPinned INTEGER NOT NULL DEFAULT 0;'); } catch(_) {}
    }
    if (oldVersion < 3) {
      // Aggiunta updatedAt per Sync 2.0
      await db.execute('ALTER TABLE users ADD COLUMN updatedAt INTEGER DEFAULT 0;');
      await db.execute('ALTER TABLE missions ADD COLUMN updatedAt INTEGER DEFAULT 0;');
    }
  }
}