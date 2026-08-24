// lib/screens/mission_list_screen.dart

import 'package:flutter/material.dart';
import '/data/models/mission_with_subtasks.dart';
import '/data/models/mission_type.dart';
import '/repository/mission_repository.dart';
import '/repository/user_repository.dart';
import '/data/session/session_manager.dart';
import '/domain/service/mission_service.dart';
import '../mission/components/mission_card.dart';
import '../mission/components/filter_status.dart'; // ✅ Importazione del nuovo file centralizzato

/// Schermata lista missioni dinamica basata sul tema attivo
class MissionListScreen extends StatefulWidget {
  final MissionService missionService;
  final MissionRepository missionRepository;
  final UserRepository userRepository;
  final SessionManager sessionManager;

  const MissionListScreen({
    super.key,
    required this.missionService,
    required this.missionRepository,
    required this.userRepository,
    required this.sessionManager,
  });

  @override
  State<MissionListScreen> createState() => _MissionListScreenState();
}

class _MissionListScreenState extends State<MissionListScreen> {
  String _searchQuery = '';
  FilterStatus _selectedFilter = FilterStatus.all;
  List<MissionWithSubTasks> _missions = [];
  String _username = 'Eroe';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = await widget.sessionManager.loggedUserId();
    if (userId == null) return;

    final missions = await widget.missionRepository.getAllMissionsWithSubTasksForUser(userId);
    final user = await widget.userRepository.getUserById(userId);

    if (!mounted) return;
    setState(() {
      _missions = missions;
      _username = user?.username ?? 'Eroe';
      _isLoading = false;
    });
  }

  List<MissionWithSubTasks> get _filteredMissions {
    return _missions.where((item) {
      final matchesSearch =
          item.mission.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              item.mission.description.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus = switch (_selectedFilter) {
        FilterStatus.all => true,
        FilterStatus.inProgress => !item.mission.completed,
        FilterStatus.completed => item.mission.completed,
      };

      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.secondary),
      );
    }

    return Column(
      children: [
        _buildHeader(context),
        _buildSearchBar(context),
        _buildFilterChips(context),
        Expanded(
          child: _filteredMissions.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: _filteredMissions.length,
            itemBuilder: (context, index) {
              final missionWithTasks = _filteredMissions[index];
              return MissionCard(
                missionWithTasks: missionWithTasks,
                onClick: () => _showMissionDetail(context, missionWithTasks),
                onEditClick: () => _showEditMissionDialog(context, missionWithTasks),
                onResetClick: () => _showResetMissionDialog(context, missionWithTasks),
                onDeleteClick: () => _handleDeleteMission(context, missionWithTasks),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Header con titolo e contatori
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.secondary;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '✦ Registro di $_username ✦',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_missions.where((m) => !m.mission.completed).length} missioni attive da compiere',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          FloatingActionButton(
            onPressed: () => _showAddMissionDialog(context),
            backgroundColor: accentColor,
            foregroundColor: theme.colorScheme.onSecondary,
            elevation: 4,
            mini: true,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.add_rounded, size: 24),
          ),
        ],
      ),
    );
  }

  /// Barra di ricerca stilizzata dinamicamente
  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.secondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Cerca tra le imprese...',
          hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
          prefixIcon: Icon(Icons.search_rounded, color: accentColor),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: accentColor.withValues(alpha: 0.2), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: accentColor, width: 1.5),
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  /// Filtri a chip orizzontali
  Widget _buildFilterChips(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildFilterChip(context, FilterStatus.all, 'Tutte', Icons.auto_awesome),
          const SizedBox(width: 8),
          _buildFilterChip(context, FilterStatus.inProgress, 'In corso', Icons.hourglass_top_rounded),
          const SizedBox(width: 8),
          _buildFilterChip(context, FilterStatus.completed, 'Completate', Icons.verified_rounded),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, FilterStatus filter, String label, IconData icon) {
    final theme = Theme.of(context);
    final isSelected = _selectedFilter == filter;
    final accentColor = theme.colorScheme.secondary;

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isSelected ? theme.colorScheme.onSecondary : accentColor,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selectedColor: accentColor,
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.onSecondary : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? accentColor : accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      onSelected: (_) => setState(() => _selectedFilter = filter),
    );
  }

  /// Stato vuoto tematico
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.secondary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shield_outlined,
              size: 48,
              color: accentColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nessuna impresa trovata',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Forgia una nuova missione per continuare l\'avventura',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Dettaglio missione in modale
  void _showMissionDetail(BuildContext context, MissionWithSubTasks missionWithTasks) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.secondary;
    final mission = missionWithTasks.mission;
    final missionType = MissionType.fromDbValue(mission.type);
    final progress = missionWithTasks.progress;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Expanded(
              child: Text(
                mission.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            if (mission.completed)
              const Icon(Icons.check_circle_rounded, color: Colors.green),
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
                          await widget.missionService.toggleSubTask(subTask, value);
                          if (!dialogContext.mounted) return;
                          Navigator.pop(dialogContext);
                          _loadData();
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
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Chiudi', style: TextStyle(color: accentColor)),
          ),
        ],
      ),
    );
  }

  /// Modale Aggiungi Missione
  void _showAddMissionDialog(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.secondary;
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedType = 'GIORNALIERO';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Forgia Nuova Missione', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titolo dell\'impresa',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Descrizione (opzionale)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo di Missione',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: ['GIORNALIERO', 'SETTIMANALE', 'SPECIALE']
                      .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type[0] + type.substring(1).toLowerCase()),
                  ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedType = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annulla', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isNotEmpty) {
                  await widget.missionService.createMissionFromForm(
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim(),
                    type: selectedType,
                    dueDate: null,
                    subtasks: [],
                  );
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                  _loadData();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: theme.colorScheme.onSecondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Crea', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  /// Modale Modifica Missione
  void _showEditMissionDialog(BuildContext context, MissionWithSubTasks missionWithTasks) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.secondary;
    final titleController = TextEditingController(text: missionWithTasks.mission.title);
    final descriptionController = TextEditingController(text: missionWithTasks.mission.description);
    String selectedType = missionWithTasks.mission.type;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Modifica Impresa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titolo',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Descrizione',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: ['GIORNALIERO', 'SETTIMANALE', 'SPECIALE']
                      .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type[0] + type.substring(1).toLowerCase()),
                  ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedType = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annulla', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isNotEmpty) {
                  await widget.missionService.updateMissionFromForm(
                    mission: missionWithTasks.mission,
                    newTitle: titleController.text.trim(),
                    newDescription: descriptionController.text.trim(),
                    newType: selectedType,
                    newSubtasksText: [],
                  );
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                  _loadData();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: theme.colorScheme.onSecondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Salva', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  /// Conferma Reset Missione
  void _showResetMissionDialog(BuildContext context, MissionWithSubTasks missionWithTasks) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Vuoi resettare l\'impresa?'),
        content: Text(
          'I progressi dei task per "${missionWithTasks.mission.title}" verranno azzerati.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annulla', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await widget.missionService.resetMission(missionWithTasks.mission.id);
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              _loadData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade800,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  /// Eliminazione con SnackBar Undo
  Future<void> _handleDeleteMission(
      BuildContext context,
      MissionWithSubTasks missionWithTasks,
      ) async {
    final theme = Theme.of(context);
    final deletedMission = missionWithTasks.mission;
    final deletedSubtasks = missionWithTasks.subTasks;

    await widget.missionService.deleteMission(deletedMission);

    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${deletedMission.title}" rimossa'),
        action: SnackBarAction(
          label: 'ANNULLA',
          textColor: theme.colorScheme.secondary,
          onPressed: () async {
            await widget.missionService.restoreMission(deletedMission, deletedSubtasks);
            _loadData();
          },
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );

    _loadData();
  }
}