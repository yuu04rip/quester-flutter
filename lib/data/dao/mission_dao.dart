// lib/data/dao/mission_dao.dart

import 'package:sqflite/sqflite.dart';
import '../models/mission.dart';
import '../models/subtask.dart';
import '../models/mission_with_subtasks.dart';

class MissionDao {
  final Database db;

  MissionDao(this.db);

  // Insert missione
  Future<int> insertMission(Mission mission) async {
    return await db.insert(
      'missions',
      mission.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Tutte le missioni per utente
  Future<List<Mission>> getAllMissionsForUser(int userId) async {
    final result = await db.query(
      'missions',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
    return result.map((map) => Mission.fromMap(map)).toList();
  }

  // Missioni con subtask
  Future<List<MissionWithSubTasks>> getAllMissionsWithSubTasksForUser(int userId) async {
    final missions = await getAllMissionsForUser(userId);
    final result = <MissionWithSubTasks>[];

    for (final mission in missions) {
      final subTasks = await db.query(
        'subtasks',
        where: 'missionId = ?',
        whereArgs: [mission.id],
      );
      result.add(MissionWithSubTasks(
        mission: mission,
        subTasks: subTasks.map((map) => SubTask.fromMap(map)).toList(),
      ));
    }

    return result;
  }

  // Missione per ID (Future)
  Future<Mission?> getMissionById(int missionId) async {
    final result = await db.query(
      'missions',
      where: 'id = ?',
      whereArgs: [missionId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Mission.fromMap(result.first);
  }

  // Update missione
  Future<void> updateMission(Mission mission) async {
    await db.update(
      'missions',
      mission.toMap(),
      where: 'id = ?',
      whereArgs: [mission.id],
    );
  }

  // Delete per ID
  Future<void> deleteMissionById(int missionId) async {
    await db.delete(
      'missions',
      where: 'id = ?',
      whereArgs: [missionId],
    );
  }

  // Conta missioni create oggi
  Future<int> countMissionsCreatedToday(int userId, int startOfDay) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM missions WHERE userId = ? AND createdAt >= ?',
      [userId, startOfDay],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Ultimo completamento
  Future<int?> getLastCompletionTime(int userId) async {
    final result = await db.rawQuery(
      'SELECT MAX(completedAt) as maxTime FROM missions WHERE userId = ? AND completed = 1',
      [userId],
    );
    return result.first['maxTime'] as int?;
  }

  // Conta completamenti recenti
  Future<int> countRecentCompletions(int userId, int timeThreshold) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM missions WHERE userId = ? AND completed = 1 AND completedAt >= ?',
      [userId, timeThreshold],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Completamenti in un range di tempo
  Future<List<Mission>> getCompletionsInTimeRange(
      int userId,
      int startTime,
      int endTime,
      ) async {
    final result = await db.query(
      'missions',
      where: 'userId = ? AND completed = 1 AND completedAt >= ? AND completedAt <= ?',
      whereArgs: [userId, startTime, endTime],
    );
    return result.map((map) => Mission.fromMap(map)).toList();
  }
}