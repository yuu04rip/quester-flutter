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
}