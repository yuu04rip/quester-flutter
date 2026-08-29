// test/shop_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:Quester/data/database/database_provider.dart';
import 'package:Quester/data/models/user.dart';
import 'package:Quester/data/models/shop_item.dart';
import 'package:Quester/data/session/session_manager.dart';
import 'package:Quester/repository/user_repository.dart';
import 'package:Quester/domain/service/shop_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('ShopService & Economy Tests', () {
    late UserRepository userRepository;
    late ShopService shopService;
    late SessionManager sessionManager;
    late int testUserId;

    setUp(() async {
      // 🛡️ Configura i valori iniziali fittizi per SharedPreferences nei test
      SharedPreferences.setMockInitialValues({});

      final databaseProvider = DatabaseProvider.instance;
      final appDb = await databaseProvider.getDatabase();
      final db = appDb.db;

      await db.execute('DELETE FROM users');
      await db.execute('DELETE FROM shop_items');
      await db.execute('DELETE FROM owned_cosmetics');

      final userDao = appDb.userDao;
      final shopDao = appDb.shopDao;
      final ownedDao = appDb.ownedCosmeticDao;

      userRepository = UserRepository(userDao: userDao, ownedCosmeticDao: ownedDao);
      sessionManager = SessionManager();

      shopService = ShopService(
        userRepository: userRepository,
        shopDao: shopDao,
        ownedDao: ownedDao,
        sessionManager: sessionManager,
      );

      testUserId = await userDao.insertUser(User(
        username: 'TestHero',
        passwordHash: 'dummy_hash',
        coins: 150,
        xpTotale: 0,
        livello: 1,
      ));

      await sessionManager.createSession(testUserId);

      await shopDao.upsertItems([
        ShopItem(
          itemId: 'test_sword',
          name: 'Spada di Legno',
          price: 100,
          description: 'Un\'arma economica',
          iconName: 'shopping_cart',
        ),
      ]);
    });

    test('Acquisto completato con successo se il giocatore ha abbastanza monete', () async {
      final success = await shopService.buyItem('test_sword');
      expect(success, isTrue);

      final user = await userRepository.getUserById(testUserId);
      expect(user?.coins, 50);

      final owned = await userRepository.getOwnedCosmetics(testUserId);
      expect(owned.any((item) => item.itemId == 'test_sword'), isTrue);
    });

    test('Acquisto fallito se il giocatore non ha abbastanza monete', () async {
      await userRepository.spendCoins(testUserId, 100);

      final success = await shopService.buyItem('test_sword');
      expect(success, isFalse);

      final user = await userRepository.getUserById(testUserId);
      expect(user?.coins, 50);
    });
  });
}