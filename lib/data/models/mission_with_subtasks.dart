// lib/models/mission_with_subtasks.dart

import 'mission.dart';
import 'subtask.dart';

class MissionWithSubTasks {
  final Mission mission;
  final List<SubTask> subTasks;

  MissionWithSubTasks({
    required this.mission,
    required this.subTasks,
  });

  double get progress {
    if (subTasks.isEmpty) return 0;
    final completedCount = subTasks.where((st) => st.done).length;
    return completedCount / subTasks.length;
  }

  int get completedCount => subTasks.where((st) => st.done).length;
  int get totalCount => subTasks.length;

  /// Converte l'oggetto in una mappa compatibile con il backend Node.js
  Map<String, dynamic> toMapForCloud() {
    final m = mission;
    return {
      'id': m.id,
      'user_id': m.userId,
      'title': m.title,
      'description': m.description,
      'type': m.type,
      'due_date': m.dueDate,
      'xp_reward': m.xpReward,
      'completed': m.completed ? 1 : 0,
      'xp_awarded': m.xpAwarded ? 1 : 0,
      'redeemed': m.redeemed ? 1 : 0,
      'created_at': m.createdAt,
      'completed_at': m.completedAt,
      'verification_level': m.verificationLevel,
      'is_pinned': m.isPinned ? 1 : 0,
      'updated_at': m.updatedAt,
      'subtasks': subTasks.map((st) => {
        'text': st.text,
        'done': st.done ? 1 : 0,
      }).toList(),
    };
  }
}