// lib/domain/service/shop_service.dart

import '../../data/models/shop_item.dart';
import '../../data/session/session_manager.dart';
import '/repository/user_repository.dart';
import '/data/dao/shop_dao.dart';
import '/data/dao/owned_cosmetic_dao.dart';

class ShopService {
  final UserRepository userRepository;
  final ShopDao shopDao;
  final OwnedCosmeticDao ownedDao;
  final SessionManager sessionManager;

  ShopService({
    required this.userRepository,
    required this.shopDao,
    required this.ownedDao,
    required this.sessionManager,
  });

  /// Acquista un item
  Future<bool> buyItem(String itemId) async {
    final userId = await sessionManager.loggedUserId();
    if (userId == null) return false;

    final item = await shopDao.getItemByItemId(itemId);
    if (item == null) return false;

    if (await ownedDao.isOwned(userId, itemId)) return false;

    final user = await userRepository.getUserById(userId);
    if (user == null) return false;
    if (user.coins < item.price) return false;

    final success = await userRepository.spendCoins(userId, item.price);
    if (!success) return false;

    await userRepository.unlockCosmetic(userId, itemId);
    return true;
  }

  /// Ottiene gli item con lo stato di possesso
  Future<List<Pair<ShopItem, bool>>> getShopItemsWithOwnership() async {
    final userId = await sessionManager.loggedUserId();
    final allItems = await shopDao.getAllItems();

    final ownedItems = <String>{};
    if (userId != null) {
      final owned = await userRepository.getOwnedCosmetics(userId);
      ownedItems.addAll(owned.map((o) => o.itemId));
    }

    return allItems.map((item) => Pair(item, ownedItems.contains(item.itemId))).toList();
  }
}

/// Classe Pair per Flutter
class Pair<T1, T2> {
  final T1 first;
  final T2 second;
  Pair(this.first, this.second);
}