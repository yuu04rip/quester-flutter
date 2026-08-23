// lib/screens/mission/components/mission_card.dart

import 'package:flutter/material.dart';
import '/data/models/mission_with_subtasks.dart';
import '/data/models/mission_type.dart';
import '/data/models/subtask.dart';
import '/ui/theme/colors.dart';

/// Card per singola missione in stile RPG Fantasy
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
    final missionType = MissionType.fromDbValue(mission.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isCompleted
                ? Colors.green.withValues(alpha: 0.6)
                : FantasyGold.withValues(alpha: 0.4),
            width: isCompleted ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          onTap: onClick,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Titolo + Badge Tipo Missione
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        mission.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted ? theme.colorScheme.onSurfaceVariant : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: FantasyGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: FantasyGold.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        missionType.label.toUpperCase(),
                        style: const TextStyle(
                          color: FantasyGold,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                if (mission.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    mission.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                // Barra di progresso
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isCompleted ? Colors.green : FantasyGold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$percentage%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? Colors.green : FantasyGold,
                      ),
                    ),
                  ],
                ),

                // Subtasks preview (se presenti)
                if (missionWithTasks.subTasks.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Divider(color: theme.colorScheme.outline.withValues(alpha: 0.2), height: 1),
                  const SizedBox(height: 8),
                  ...missionWithTasks.subTasks.map((task) => _buildSubtaskItem(context, task)),
                ],

                const SizedBox(height: 8),
                const Divider(height: 1, thickness: 0.5),
                const SizedBox(height: 8),

                // Footer: Ricompense ed Azioni
                Row(
                  children: [
                    // XP Reward
                    const Icon(Icons.star_rounded, size: 16, color: FantasyGold),
                    const SizedBox(width: 2),
                    Text(
                      '+${missionType.xpReward}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: FantasyGold),
                    ),
                    const SizedBox(width: 10),
                    // Coin Reward
                    Image.asset('assets/images/coin.png', width: 14, height: 14),
                    const SizedBox(width: 4),
                    Text(
                      '+${missionType.coinReward}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: FantasyGold),
                    ),
                    const Spacer(),

                    // Pulsante Reset (se applicabile)
                    if (_shouldShowReset() && onResetClick != null)
                      SizedBox(
                        height: 32,
                        width: 32,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.restart_alt_rounded, size: 16),
                          color: Colors.orange,
                          onPressed: onResetClick,
                          tooltip: 'Resetta',
                        ),
                      ),

                    // Pulsante Modifica
                    SizedBox(
                      height: 32,
                      width: 32,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        color: theme.colorScheme.onSurfaceVariant,
                        onPressed: onEditClick,
                        tooltip: 'Modifica',
                      ),
                    ),

                    // Pulsante Elimina
                    SizedBox(
                      height: 32,
                      width: 32,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.delete_outline_rounded, size: 16),
                        color: Colors.redAccent.shade200,
                        onPressed: onDeleteClick,
                        tooltip: 'Elimina',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubtaskItem(BuildContext context, SubTask task) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: Checkbox(
              value: task.done,
              onChanged: null, // Sola lettura nella card, si spunta nel dettaglio
              activeColor: FantasyGold,
              checkColor: FantasyBackground,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              task.text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: task.done
                    ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                    : theme.colorScheme.onSurface,
                decoration: task.done ? TextDecoration.lineThrough : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowReset() {
    final hasSubtasks = missionWithTasks.subTasks.isNotEmpty;
    final hasCompletedSubtask = missionWithTasks.subTasks.any((t) => t.done);
    return !missionWithTasks.mission.completed && hasSubtasks && hasCompletedSubtask;
  }
}