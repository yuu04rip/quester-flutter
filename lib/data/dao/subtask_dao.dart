// lib/data/dao/subtask_dao.dart

import 'package:sqflite/sqflite.dart';
import '../models/subtask.dart';

class SubTaskDao {
  final DatabaseExecutor db;

  SubTaskDao(this.db);

  // Insert lista di subtask
  Future<void> insertSubTasks(List<SubTask> subTasks) async {
    final batch = (db as dynamic).batch();
    for (final subTask in subTasks) {
      batch.insert(
        'subtasks',
        subTask.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // Update subtask
  Future<void> updateSubTask(SubTask subTask) async {
    await db.update(
      'subtasks',
      subTask.toMap(),
      where: 'id = ?',
      whereArgs: [subTask.id],
    );
  }

  // Subtask per missione
  Future<List<SubTask>> getSubTasksByMissionId(int missionId) async {
    final result = await db.query(
      'subtasks',
      where: 'missionId = ?',
      whereArgs: [missionId],
    );
    return result.map((map) => SubTask.fromMap(map)).toList();
  }

  // Conta tutti i subtask
  Future<int> countAllSubTasks(int missionId) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM subtasks WHERE missionId = ?',
      [missionId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Conta subtask completati
  Future<int> countCompletedSubTasks(int missionId) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM subtasks WHERE missionId = ? AND done = 1',
      [missionId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Elimina subtask per missione
  Future<void> deleteSubTasksForMission(int missionId) async {
    await db.delete(
      'subtasks',
      where: 'missionId = ?',
      whereArgs: [missionId],
    );
  }
}