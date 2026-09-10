// lib/domain/service/mission_service.dart

import '../../data/dao/mission_dao.dart';
import '../../data/dao/user_dao.dart';
import '../../data/dao/subtask_dao.dart';
import '../../data/dao/owned_cosmetic_dao.dart';
import '../../data/models/mission.dart';
import '../../data/models/mission_type.dart';
import '../../data/models/subtask.dart';
import '/repository/mission_repository.dart';
import '/repository/user_repository.dart';
import '../../data/session/session_manager.dart';
import 'currency_service.dart';
import 'reminder_service.dart';
import 'sync_service.dart';

class MissionService {
  static const int maxSubtasksPerMission = 10;
  static const int minTimeBetweenCompletions = 30000;

  final MissionRepository missionRepository;
  final UserRepository userRepository;
  final CurrencyService currencyService;
  final SessionManager sessionManager;
  final ReminderService? reminderService;
  final SyncService? syncService;
  final bool isTestMode;

  MissionService({
    required this.missionRepository,
    required this.userRepository,
    required this.currencyService,
    required this.sessionManager,
    this.reminderService,
    this.syncService,
    this.isTestMode = false,
  });

  /// Creazione missione
  Future<void> createMissionFromForm({
    required String title,
    String? description,
    required String type,
    String? dueDate,
    List<String> subtasks = const [],
  }) async {
    final userId = await sessionManager.loggedUserId();
    if (userId == null) {
      throw Exception('Impossibile creare una missione: nessun utente autenticato');
    }

    if (title.trim().isEmpty) {
      throw Exception('Il titolo è obbligatorio');
    }

    final missionType = MissionType.fromDbValue(type);
    final validXp = missionType.xpReward;

    final cleanSubtasks = subtasks.map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    if (cleanSubtasks.length > maxSubtasksPerMission) {
      throw Exception('Massimo $maxSubtasksPerMission subtask per missione');
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final mission = Mission(
      userId: userId,
      title: title.trim(),
      description: description?.trim() ?? '',
      type: missionType.dbValue,
      dueDate: dueDate,
      xpReward: validXp,
      createdAt: now,
      updatedAt: now,
      verificationLevel: validXp > 200 ? 'MANUAL' : 'AUTO',
    );

    final missionId = await missionRepository.createMission(mission, cleanSubtasks);

    // Sync mirato della sola nuova missione
    if (syncService != null) {
      await syncService!.syncSingleMissionWithSubTasks(missionId, userId);
    }

    if (reminderService != null) {
      await reminderService!.scheduleMissionReminder(
        missionId: missionId,
        missionTitle: title.trim(),
        delayMinutes: 10,
      );
    }
  }

  /// Aggiorna missione dal form
  Future<void> updateMissionFromForm({
    required Mission mission,
    required String newTitle,
    required String newDescription,
    required String newType,
    required List<String> newSubtasksText,
  }) async {
    if (newTitle.trim().isEmpty) {
      throw Exception('Il titolo è obbligatorio');
    }

    if (mission.completed) {
      throw Exception('Impossibile modificare una missione già completata');
    }

    final userId = await sessionManager.loggedUserId();
    if (userId == null) throw Exception('Utente non autenticato');

    if (mission.userId != userId) {
      throw Exception('Non autorizzato');
    }

    final cleanSubtasks = newSubtasksText
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (cleanSubtasks.length > maxSubtasksPerMission) {
      throw Exception('Massimo $maxSubtasksPerMission subtask per missione');
    }

    final missionType = MissionType.fromDbValue(newType);
    final validXp = missionType.xpReward;
    final now = DateTime.now().millisecondsSinceEpoch;

    final updatedMission = mission.copyWith(
      title: newTitle.trim(),
      description: newDescription.trim(),
      type: missionType.dbValue,
      xpReward: validXp,
      updatedAt: now,
    );

    final missionId = mission.id;
    if (missionId == null) {
      throw Exception('Impossibile aggiornare una missione senza ID');
    }

    final subtaskList = cleanSubtasks.map((text) => SubTask(
      missionId: missionId,
      text: text,
      done: false,
    )).toList();

    await missionRepository.updateMissionWithSubTasks(updatedMission, subtaskList);

    // TRIGGER SYNC CLOUD
    if (syncService != null) {
      await syncService!.syncSingleMissionWithSubTasks(missionId, userId);
    }
  }

  /// Completamento missione
  Future<void> completeMission(Mission mission, int userId) async {
    final missionId = mission.id;
    if (missionId == null) return;

    if (mission.completed) {
      throw Exception('Questa missione è già stata completata!');
    }

    final lastCompletion = await missionRepository.getLastCompletionTime(userId);
    if (lastCompletion != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - lastCompletion < minTimeBetweenCompletions) {
        throw Exception('Stai completando le missioni troppo velocemente! Attendi un momento.');
      }
    }

    final missionType = MissionType.fromDbValue(mission.type);
    final finalXp = missionType.xpReward;
    final finalCoins = missionType.coinReward;

    final appDb = missionRepository.missionDao.db;

    await (appDb as dynamic).transaction((txn) async {
      final txnMissionDao = MissionDao(txn);
      final txnUserDao = UserDao(txn);
      final txnSubTaskDao = SubTaskDao(txn);
      final txnOwnedCosmeticDao = OwnedCosmeticDao(txn);

      final txnMissionRepo = MissionRepository(
        missionDao: txnMissionDao,
        subTaskDao: txnSubTaskDao,
      );
      final txnUserRepo = UserRepository(
        userDao: txnUserDao,
        ownedCosmeticDao: txnOwnedCosmeticDao,
      );

      await txnMissionRepo.markMissionCompleted(missionId);
      await txnUserRepo.addXp(userId, finalXp);
      await txnUserRepo.addCoins(userId, finalCoins);
    });

    userRepository.refresh();

    // TRIGGER SYNC CLOUD
    if (syncService != null) {
      await syncService!.syncSingleMissionWithSubTasks(missionId, userId);
      final updatedUser = await userRepository.getUserById(userId);
      if (updatedUser != null) {
        await syncService!.pushUserToCloud(updatedUser);
      }
    }

    final updatedUser = await userRepository.getUserById(userId);
    final playerLevel = updatedUser?.livello ?? 1;

    if (reminderService != null) {
      await reminderService!.cancelMissionReminder(missionId);
      await reminderService!.sendMissionCompletionNotification(
        missionId: missionId,
        missionTitle: mission.title,
        xpGained: finalXp,
        coinsGained: finalCoins,
        playerLevel: playerLevel,
      );
    }
  }

  /// Toggle subtask
  Future<void> toggleSubTask(SubTask subTask, bool done) async {
    final userId = await sessionManager.loggedUserId();
    if (userId == null) throw Exception('Utente non autenticato');

    final mission = await missionRepository.getMissionById(subTask.missionId);
    if (mission == null) throw Exception('Missione non trovata');

    if (mission.userId != userId) throw Exception('Non autorizzato');
    if (mission.completed) throw Exception('Missione già completata');

    final now = DateTime.now().millisecondsSinceEpoch;

    await missionRepository.updateSubTask(subTask.copyWith(done: done));

    final updatedMission = mission.copyWith(updatedAt: now);
    await missionRepository.updateMission(updatedMission);

    final allDone = await missionRepository.isMissionFullyCompleted(subTask.missionId);

    if (allDone) {
      final currentMission = await missionRepository.getMissionById(subTask.missionId);
      if (currentMission != null && !currentMission.completed) {
        await completeMission(currentMission, userId);
      }
    } else {
      if (syncService != null) {
        await syncService!.syncSingleMissionWithSubTasks(subTask.missionId, userId);
      }
    }
  }

  /// Elimina missione
  Future<void> deleteMission(Mission mission) async {
    final userId = await sessionManager.loggedUserId();
    if (userId == null) throw Exception('Utente non autenticato');

    if (mission.userId != userId) {
      throw Exception('Non autorizzato');
    }

    if (mission.id != null && reminderService != null) {
      await reminderService!.cancelMissionReminder(mission.id!);
    }

    await missionRepository.deleteMission(mission);

    if (mission.id != null && syncService != null) {
      await syncService!.deleteMissionOnCloud(mission.id!);
    }
  }

  /// Ripristina missione eliminata
  Future<void> restoreMission(Mission mission, List<SubTask> subTasks) async {
    await missionRepository.restoreMission(mission, subTasks);
    if (mission.id != null && syncService != null) {
      await syncService!.syncSingleMissionWithSubTasks(mission.id!, mission.userId);
    }
  }

  /// Reset missione
  Future<void> resetMission(int missionId) async {
    final userId = await sessionManager.loggedUserId();
    if (userId == null) throw Exception('Utente non autenticato');

    final mission = await missionRepository.getMissionById(missionId);
    if (mission == null) throw Exception('Missione non trovata');

    if (mission.userId != userId) throw Exception('Non autorizzato');

    final now = DateTime.now().millisecondsSinceEpoch;

    final subtasks = await missionRepository.getSubTasksByMissionId(missionId);
    for (final subtask in subtasks) {
      if (subtask.done) {
        await missionRepository.updateSubTask(subtask.copyWith(done: false));
      }
    }

    final resetMissionObj = mission.copyWith(completed: false, updatedAt: now);
    await missionRepository.updateMission(resetMissionObj);

    if (syncService != null) {
      await syncService!.syncSingleMissionWithSubTasks(missionId, userId);
    }
  }
}