// lib/data/database/app_database.dart

import 'package:sqflite/sqflite.dart';
import '../dao/mission_dao.dart';
import '../dao/owned_cosmetic_dao.dart';
import '../dao/shop_dao.dart';
import '../dao/subtask_dao.dart';
import '../dao/user_dao.dart';

class AppDatabase {
  static const String dbName = 'quester_db';
  static const int dbVersion = 2; // <-- Aggiornato a 2 per la migrazione

  final Database db;
  late final UserDao userDao;
  late final MissionDao missionDao;
  late final SubTaskDao subTaskDao;
  late final ShopDao shopDao;
  late final OwnedCosmeticDao ownedCosmeticDao;

  AppDatabase(this.db) {
    userDao = UserDao(db);
    missionDao = MissionDao(db);
    subTaskDao = SubTaskDao(db);
    shopDao = ShopDao(db);
    ownedCosmeticDao = OwnedCosmeticDao(db);
  }
}