// lib/screens/mission/components/mission_detail_dialog.dart

import 'package:flutter/material.dart';
import '/data/models/mission_with_subtasks.dart';
import '/data/models/mission_type.dart';
import '/domain/service/mission_service.dart';

class MissionDetailDialog extends StatelessWidget {
  final MissionWithSubTasks missionWithTasks;
  final MissionService missionService;
  final VoidCallback onSubTaskToggled;

  const MissionDetailDialog({
    super.key,
    required this.missionWithTasks,
    required this.missionService,
    required this.onSubTaskToggled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.secondary;
    final mission = missionWithTasks.mission;
    final missionType = MissionType.fromDbValue(mission.type);
    final progress = missionWithTasks.progress;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Expanded(
            child: Text(
              mission.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          if (mission.completed) const Icon(Icons.check_circle_rounded, color: Colors.green),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  missionType.label.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: accentColor),
                ),
              ),
              if (mission.description.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(mission.description, style: const TextStyle(fontSize: 14)),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.star_rounded, size: 18, color: accentColor),
                  const SizedBox(width: 4),
                  Text('+${missionType.xpReward} XP',
                      style: TextStyle(fontWeight: FontWeight.bold, color: accentColor)),
                  const SizedBox(width: 16),
                  Image.asset('assets/images/coin.png', width: 18, height: 18),
                  const SizedBox(width: 4),
                  Text('+${missionType.coinReward} Monete',
                      style: TextStyle(fontWeight: FontWeight.bold, color: accentColor)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          mission.completed ? Colors.green : accentColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('${(progress * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Subtasks (${missionWithTasks.completedCount}/${missionWithTasks.totalCount}):',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              if (missionWithTasks.subTasks.isEmpty)
                const Text('Nessuna subtask associata.', style: TextStyle(color: Colors.grey, fontSize: 13))
              else
                ...missionWithTasks.subTasks.map((subTask) {
                  return CheckboxListTile(
                    title: Text(subTask.text, style: const TextStyle(fontSize: 13)),
                    value: subTask.done,
                    activeColor: accentColor,
                    checkColor: theme.colorScheme.onSecondary,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    onChanged: (value) async {
                      if (value != null) {
                        await missionService.toggleSubTask(subTask, value);
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        onSubTaskToggled();
                      }
                    },
                  );
                }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Chiudi', style: TextStyle(color: accentColor)),
        ),
      ],
    );
  }
}