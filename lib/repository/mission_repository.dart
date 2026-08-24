// lib/data/repository/mission_repository.dart

import '../data/dao/mission_dao.dart';
import '../data/dao/subtask_dao.dart';
import '../data/models/mission.dart';
import '../data/models/mission_with_subtasks.dart';
import '../data/models/subtask.dart';

class MissionRepository {
  final MissionDao missionDao;
  final SubTaskDao subTaskDao;

  MissionRepository({
    required this.missionDao,
    required this.subTaskDao,
  });

  /// Tutte le missioni per utente
  Future<List<Mission>> getAllMissionsForUser(int userId) async {
    return missionDao.getAllMissionsForUser(userId);
  }

  /// Missioni con subtask per utente
  Future<List<MissionWithSubTasks>> getAllMissionsWithSubTasksForUser(int userId) async {
    return missionDao.getAllMissionsWithSubTasksForUser(userId);
  }

  /// Missione per ID
  Future<Mission?> getMissionById(int missionId) async {
    return missionDao.getMissionById(missionId);
  }

  /// Subtask per missione
  Future<List<SubTask>> getSubTasksByMissionId(int missionId) async {
    return subTaskDao.getSubTasksByMissionId(missionId);
  }

  /// Creazione missione con subtask
  Future<int> createMission(Mission mission, List<String> subTasks) async {
    final missionId = await missionDao.insertMission(mission);

    if (subTasks.isNotEmpty) {
      final items = subTasks.map((text) => SubTask(
        missionId: missionId,
        text: text,
      )).toList();
      await subTaskDao.insertSubTasks(items);
    }

    return missionId;
  }

  /// Update missione
  Future<void> updateMission(Mission mission) async {
    await missionDao.updateMission(mission);
  }

  /// Update missione con sostituzione subtask
  Future<void> updateMissionWithSubTasks(Mission mission, List<SubTask> subtasks) async {
    final missionId = mission.id;
    if (missionId == null) {
      throw Exception('Impossibile aggiornare una missione senza ID');
    }

    await missionDao.updateMission(mission);
    await subTaskDao.deleteSubTasksForMission(missionId);

    if (subtasks.isNotEmpty) {
      final newSubtasks = subtasks.map((st) => SubTask(
        missionId: missionId,
        text: st.text,
        done: st.done,
      )).toList();
      await subTaskDao.insertSubTasks(newSubtasks);
    }
  }

  /// Update subtask
  Future<void> updateSubTask(SubTask subTask) async {
    await subTaskDao.updateSubTask(subTask);
  }

  /// Verifica se tutti i subtask sono completati
  Future<bool> isMissionFullyCompleted(int missionId) async {
    final done = await subTaskDao.countCompletedSubTasks(missionId);
    final total = await subTaskDao.countAllSubTasks(missionId);
    return total > 0 && done == total;
  }

  /// Marca missione completata
  Future<void> markMissionCompleted(int missionId) async {
    final mission = await missionDao.getMissionById(missionId);
    if (mission == null || mission.completed) return;

    await missionDao.updateMission(mission.copyWith(
      completed: true,
      completedAt: DateTime.now().millisecondsSinceEpoch,
    ));
  }

  /// Marca XP assegnati
  Future<void> markMissionXpAwarded(int missionId) async {
    final mission = await missionDao.getMissionById(missionId);
    if (mission == null || mission.xpAwarded) return;
    await missionDao.updateMission(mission.copyWith(xpAwarded: true));
  }

  /// Riscatta missione
  Future<void> redeemMission(int missionId) async {
    final mission = await missionDao.getMissionById(missionId);
    if (mission == null || mission.redeemed) return;
    await missionDao.updateMission(mission.copyWith(redeemed: true));
  }

  /// Elimina missione
  Future<void> deleteMission(Mission mission) async {
    final missionId = mission.id;
    if (missionId == null) return;
    await missionDao.deleteMissionById(missionId);
  }

  /// Ripristina missione
  Future<void> restoreMission(Mission mission, List<SubTask> subTasks) async {
    await missionDao.insertMission(mission);
    if (subTasks.isNotEmpty) {
      await subTaskDao.insertSubTasks(subTasks);
    }
  }

  /// Conta missioni create oggi
  Future<int> countMissionsCreatedToday(int userId) async {
    final startOfDay = _getStartOfDay();
    return missionDao.countMissionsCreatedToday(userId, startOfDay);
  }

  /// Ultimo completamento
  Future<int?> getLastCompletionTime(int userId) async {
    return missionDao.getLastCompletionTime(userId);
  }

  /// Conta completamenti recenti
  Future<int> countRecentCompletions(int userId, int timeThreshold) async {
    return missionDao.countRecentCompletions(userId, timeThreshold);
  }

  /// Completamenti in un range
  Future<List<Mission>> getCompletionsInTimeRange(int userId, int startTime, int endTime) async {
    return missionDao.getCompletionsInTimeRange(userId, startTime, endTime);
  }

  /// Inizio della giornata
  int _getStartOfDay() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
  }
}