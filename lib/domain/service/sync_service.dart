// lib/domain/service/sync_service.dart

import 'package:flutter/foundation.dart';
import '/domain/service/api_service.dart';
import '/repository/user_repository.dart';
import '/repository/mission_repository.dart';
import '../../data/models/user.dart';

class SyncService {
  final UserRepository userRepository;
  final MissionRepository missionRepository;

  SyncService({
    required this.userRepository,
    required this.missionRepository,
  });

  Future<void> syncSingleMissionWithSubTasks(int missionId, int userId) async {
    try {
      final missions = await missionRepository.getAllMissionsWithSubTasksForUser(userId);
      final missionWithSubtasks = missions.where((m) => m.mission.id == missionId).firstOrNull;

      if (missionWithSubtasks != null) {
        await ApiService.syncMission(missionWithSubtasks.toMapForCloud());
      }
    } catch (e) {
      debugPrint('[SYNC] Errore sincronizzazione singola missione: $e');
    }
  }

  Future<void> pushUserToCloud(User user) async {
    try {
      await ApiService.syncUser(user);
    } catch (e) {
      debugPrint('[SYNC] Errore sincronizzazione utente: $e');
    }
  }

  Future<void> deleteMissionOnCloud(int missionId) async {
    try {
      await ApiService.deleteMissionOnCloud(missionId);
    } catch (e) {
      debugPrint('[SYNC] Errore eliminazione cloud missione: $e');
    }
  }

  Future<void> pushLocalDataToCloud(int userId) async {
    try {
      debugPrint('[SYNC] Avvio PUSH dati locali verso Cloud...');

      final user = await userRepository.getUserById(userId);
      if (user != null) {
        await ApiService.syncUser(user);
      }

      final missions = await missionRepository.getAllMissionsWithSubTasksForUser(userId);
      for (var mWithS in missions) {
        await ApiService.syncMission(mWithS.toMapForCloud());
      }

      // Sincronizzazione Inventario (Cosmetici posseduti)
      final owned = await userRepository.getOwnedCosmetics(userId);
      final itemIds = owned.map((o) => o.itemId).toList();
      await ApiService.syncOwnedCosmetics(userId, itemIds);

      debugPrint('[SYNC] PUSH completato.');
    } catch (e) {
      debugPrint('[SYNC] Errore durante il PUSH: $e');
    }
  }

  Future<void> pullCloudDataToLocal(int userId) async {
    try {
      debugPrint('[SYNC] Avvio PULL dati dal Cloud verso Locale...');

      final cloudData = await ApiService.fetchUserDataFromCloud(userId);
      if (cloudData == null) {
        debugPrint('[SYNC] PULL: Nessun dato ricevuto dal Cloud.');
        return;
      }

      if (cloudData['user'] != null) {
        debugPrint('[SYNC] PULL: Sincronizzazione profilo utente...');
        await userRepository.saveOrUpdateUserFromCloud(cloudData['user']);
      }

      final dynamic missionsData = cloudData['missions'];
      if (missionsData is List) {
        debugPrint('[SYNC] PULL: Sincronizzazione di ${missionsData.length} missioni...');
        for (var mData in missionsData) {
          try {
            await userRepository.saveMissionFromCloud(mData);
          } catch (e) {
            debugPrint('[SYNC] Errore salvataggio singola missione: $e');
          }
        }
      }

      // Sincronizzazione Inventario (Download cosmetici)
      final dynamic ownedItems = cloudData['owned_items'];
      if (ownedItems is List) {
        debugPrint('[SYNC] PULL: Sincronizzazione di ${ownedItems.length} cosmetici...');
        for (var itemId in ownedItems) {
          await userRepository.unlockCosmetic(userId, itemId.toString());
        }
      }

      debugPrint('[SYNC] PULL completato.');
    } catch (e, stack) {
      debugPrint('[SYNC] Errore critico durante il PULL: $e');
      debugPrint('Stacktrace: $stack');
    }
  }

  Future<void> performFullSync(int userId) async {
    await pullCloudDataToLocal(userId);
    await pushLocalDataToCloud(userId);
  }
}