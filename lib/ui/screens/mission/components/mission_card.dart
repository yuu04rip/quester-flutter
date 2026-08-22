// lib/screens/mission/components/mission_card.dart

import 'package:flutter/material.dart';
import '/data/models/mission_with_subtasks.dart';
import '/data/models/subtask.dart';
import '/ui/theme/colors.dart';

/// Card per singola missione
class MissionCard extends StatelessWidget {
  final MissionWithSubTasks missionWithTasks;
  final VoidCallback onClick;
  final VoidCallback onEditClick;
  final VoidCallback onDeleteClick;
  final VoidCallback? onResetClick;

  const MissionCard({
    super.key,
    required this.missionWithTasks,
    required this.onClick,
    required this.onEditClick,
    required this.onDeleteClick,
    this.onResetClick,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mission = missionWithTasks.mission;
    final progress = missionWithTasks.progress;
    final percentage = (progress * 100).toInt();
    final isCompleted = mission.completed;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onClick,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      mission.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  if (_shouldShowReset() && onResetClick != null)
                    IconButton(
                      onPressed: onResetClick,
                      icon: const Icon(Icons.refresh, color: Colors.orange, size: 20),
                    ),
                  IconButton(
                    onPressed: onEditClick,
                    icon: Icon(Icons.edit, color: theme.colorScheme.primary, size: 20),
                  ),
                  IconButton(
                    onPressed: onDeleteClick,
                    icon: Icon(Icons.delete, color: theme.colorScheme.error, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Progress bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 16,
                        backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          percentage == 100 ? Colors.green : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: percentage == 100 ? Colors.green : theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              // Subtasks
              if (missionWithTasks.subTasks.isNotEmpty) ...[
                const SizedBox(height: 16),
                Divider(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                const SizedBox(height: 8),
                Text(
                  'Obiettivi:',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                ...missionWithTasks.subTasks.map((task) => _buildSubtaskItem(context, task)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubtaskItem(BuildContext context, SubTask task) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Checkbox(
          value: task.done,
          onChanged: null,
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(width: 8),
        Text(
          task.text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: task.done
                ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                : theme.colorScheme.onSurface,
            decoration: task.done ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }

  bool _shouldShowReset() {
    final hasSubtasks = missionWithTasks.subTasks.isNotEmpty;
    final hasCompletedSubtask = missionWithTasks.subTasks.any((t) => t.done);
    return !missionWithTasks.mission.completed && hasSubtasks && hasCompletedSubtask;
  }
}