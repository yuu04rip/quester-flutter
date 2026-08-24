// lib/domain/service/mission_service.dart

import '../../data/models/mission.dart';
import '../../data/models/mission_type.dart';
import '../../data/models/subtask.dart';
import '/repository/mission_repository.dart';
import '/repository/user_repository.dart';
import '../../data/session/session_manager.dart';
import 'currency_service.dart';

class MissionService {
  static const int MAX_SUBTASKS_PER_MISSION = 10;
  static const int MIN_TIME_BETWEEN_COMPLETIONS = 30000;
  static const int MIN_TIME_PER_MISSION = 30000;

  final MissionRepository missionRepository;
  final UserRepository userRepository;
  final CurrencyService currencyService;
  final SessionManager sessionManager;
  final bool isTestMode;

  MissionService({
    required this.missionRepository,
    required this.userRepository,
    required this.currencyService,
    required this.sessionManager,
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
    if (cleanSubtasks.length > MAX_SUBTASKS_PER_MISSION) {
      throw Exception('Massimo $MAX_SUBTASKS_PER_MISSION subtask per missione');
    }

    final mission = Mission(
      userId: userId,
      title: title.trim(),
      description: description?.trim() ?? '',
      type: missionType.dbValue,
      dueDate: dueDate,
      xpReward: validXp,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      verificationLevel: validXp > 200 ? 'MANUAL' : 'AUTO',
    );

    await missionRepository.createMission(mission, cleanSubtasks);
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

    if (cleanSubtasks.length > MAX_SUBTASKS_PER_MISSION) {
      throw Exception('Massimo $MAX_SUBTASKS_PER_MISSION subtask per missione');
    }

    final missionType = MissionType.fromDbValue(newType);
    final validXp = missionType.xpReward;

    final updatedMission = mission.copyWith(
      title: newTitle.trim(),
      description: newDescription.trim(),
      type: missionType.dbValue,
      xpReward: validXp,
    );

    // Gestione sicura dell'id poichè ora è int? nel nuovo modello
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
  }

  /// Completamento missione
  Future<void> completeMission(Mission mission, int userId) async {
    final missionId = mission.id;
    if (missionId == null) return;

    if (!mission.completed) {
      final user = await userRepository.getUserById(userId);
      if (user == null) throw Exception('Utente non trovato');

      final missionType = MissionType.fromDbValue(mission.type);
      final finalXp = missionType.xpReward;
      final finalCoins = missionType.coinReward;

      await missionRepository.markMissionCompleted(missionId);
      await userRepository.addXp(userId, finalXp);
      await userRepository.addCoins(userId, finalCoins);
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

    await missionRepository.updateSubTask(subTask.copyWith(done: done));

    final allDone = await missionRepository.isMissionFullyCompleted(subTask.missionId);

    if (allDone) {
      final currentMission = await missionRepository.getMissionById(subTask.missionId);
      if (currentMission != null) {
        await completeMission(currentMission, userId);
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

    await missionRepository.deleteMission(mission);
  }

  /// Ripristina missione eliminata
  Future<void> restoreMission(Mission mission, List<SubTask> subTasks) async {
    await missionRepository.restoreMission(mission, subTasks);
  }

  /// Reset missione
  Future<void> resetMission(int missionId) async {
    final userId = await sessionManager.loggedUserId();
    if (userId == null) throw Exception('Utente non autenticato');

    final mission = await missionRepository.getMissionById(missionId);
    if (mission == null) throw Exception('Missione non trovata');

    if (mission.userId != userId) throw Exception('Non autorizzato');

    final subtasks = await missionRepository.getSubTasksByMissionId(missionId);
    for (final subtask in subtasks) {
      if (subtask.done) {
        await missionRepository.updateSubTask(subtask.copyWith(done: false));
      }
    }

    if (mission.completed && !mission.xpAwarded) {
      await missionRepository.updateMission(mission.copyWith(completed: false));
    }
  }
}