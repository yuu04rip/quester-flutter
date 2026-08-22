// lib/screens/mission_list_screen.dart

import 'package:flutter/material.dart';
import '/data/models/mission.dart';
import '/data/models/mission_with_subtasks.dart';
import '/repository/mission_repository.dart';
import '/repository/user_repository.dart';
import '/data/session/session_manager.dart';
import '/domain/service/mission_service.dart';
import '/ui/theme/colors.dart';

/// Filtro per lo stato delle missioni
enum FilterStatus {
  all,
  inProgress,
  completed,
}

/// Schermata lista missioni
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
  // Stato
  int? _selectedMissionId;
  MissionWithSubTasks? _missionToEdit;
  bool _showAddDialog = false;
  MissionWithSubTasks? _missionToReset;
  String _searchQuery = '';
  FilterStatus _selectedFilter = FilterStatus.all;

  // Dati
  List<MissionWithSubTasks> _missions = [];
  String _username = 'Eroe';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Carica missioni e utente
  Future<void> _loadData() async {
    final userId = await widget.sessionManager.loggedUserId();
    if (userId == null) return;

    final missions = await widget.missionRepository.getAllMissionsWithSubTasksForUser(userId);
    final user = await widget.userRepository.getUserById(userId);

    setState(() {
      _missions = missions;
      _username = user?.username ?? 'Eroe';
      _isLoading = false;
    });
  }

  /// Missioni filtrate
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
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
            padding: const EdgeInsets.all(16),
            itemCount: _filteredMissions.length,
            itemBuilder: (context, index) {
              return _buildMissionCard(context, _filteredMissions[index]);
            },
          ),
        ),
      ],
    );
  }

  /// Header con titolo e pulsante aggiungi
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '✦ Missioni di $_username ✦',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_missions.length} missioni totali',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          FloatingActionButton(
            onPressed: () => _showAddMissionDialog(context),
            backgroundColor: theme.colorScheme.secondary,
            mini: true,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  /// Barra di ricerca
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Cerca missione...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          isDense: true,
        ),
      ),
    );
  }

  /// Filtri
  Widget _buildFilterChips(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildFilterChip(context, FilterStatus.all, 'Tutte'),
          _buildFilterChip(context, FilterStatus.inProgress, 'In corso'),
          _buildFilterChip(context, FilterStatus.completed, 'Completate'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, FilterStatus filter, String label) {
    final isSelected = _selectedFilter == filter;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedFilter = filter),
      ),
    );
  }

  /// Stato vuoto
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 48,
            color: theme.colorScheme.secondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Nessuna missione trovata',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Card missione
  Widget _buildMissionCard(BuildContext context, MissionWithSubTasks missionWithTasks) {
    final theme = Theme.of(context);
    final mission = missionWithTasks.mission;
    final isCompleted = mission.completed;
    final progress = missionWithTasks.progress;

    return Card(
      elevation: 8,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isCompleted
              ? Colors.green.withValues(alpha: 0.5)
              : theme.colorScheme.secondary.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: () => _showMissionDetail(context, missionWithTasks),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      mission.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  if (isCompleted)
                    const Icon(Icons.check_circle, color: Colors.green)
                  else
                    const Icon(Icons.circle_outlined),
                ],
              ),
              if (mission.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  mission.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? Colors.green : FantasyGold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: FantasyGold),
                      const SizedBox(width: 4),
                      Text('${mission.xpReward} XP'),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () => _showEditMissionDialog(context, missionWithTasks),
                      ),
                      IconButton(
                        icon: const Icon(Icons.restart_alt, size: 18),
                        onPressed: () => _showResetMissionDialog(context, missionWithTasks),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                        onPressed: () => _handleDeleteMission(context, missionWithTasks),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Dialog dettaglio missione
  void _showMissionDetail(BuildContext context, MissionWithSubTasks missionWithTasks) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(missionWithTasks.mission.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(missionWithTasks.mission.description),
            const SizedBox(height: 8),
            Text('Tipo: ${missionWithTasks.mission.type}'),
            Text('XP: ${missionWithTasks.mission.xpReward}'),
            const SizedBox(height: 16),
            Text(
              'Subtask (${missionWithTasks.completedCount}/${missionWithTasks.totalCount}):',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...missionWithTasks.subTasks.map((subTask) {
              return CheckboxListTile(
                title: Text(subTask.text),
                value: subTask.done,
                onChanged: (value) async {
                  if (value != null) {
                    await widget.missionService.toggleSubTask(subTask, value);
                    Navigator.pop(dialogContext);
                    _loadData();
                  }
                },
                dense: true,
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }

  /// Dialog aggiungi missione
  void _showAddMissionDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedType = 'GIORNALIERO';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Nuova Missione'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Titolo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrizione',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
                items: ['GIORNALIERO', 'SETTIMANALE', 'SPECIALE']
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.toLowerCase()),
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annulla'),
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
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                  _loadData();
                }
              },
              child: const Text('Crea'),
            ),
          ],
        ),
      ),
    );
  }

  /// Dialog modifica missione
  void _showEditMissionDialog(BuildContext context, MissionWithSubTasks missionWithTasks) {
    final titleController = TextEditingController(text: missionWithTasks.mission.title);
    final descriptionController = TextEditingController(text: missionWithTasks.mission.description);
    String selectedType = missionWithTasks.mission.type;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Modifica Missione'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Titolo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrizione',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
                items: ['GIORNALIERO', 'SETTIMANALE', 'SPECIALE']
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.toLowerCase()),
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annulla'),
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
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                  _loadData();
                }
              },
              child: const Text('Salva'),
            ),
          ],
        ),
      ),
    );
  }

  /// Dialog reset missione
  void _showResetMissionDialog(BuildContext context, MissionWithSubTasks missionWithTasks) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Resettare la missione?'),
        content: Text(
          'I task della missione "${missionWithTasks.mission.title}" verranno resettati.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () async {
              await widget.missionService.resetMission(missionWithTasks.mission.id);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
              _loadData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  /// Gestione eliminazione missione
  Future<void> _handleDeleteMission(
      BuildContext context,
      MissionWithSubTasks missionWithTasks,
      ) async {
    final deletedMission = missionWithTasks.mission;
    final deletedSubtasks = missionWithTasks.subTasks;

    await widget.missionService.deleteMission(deletedMission);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${deletedMission.title}" eliminata'),
        action: SnackBarAction(
          label: 'ANNULLA',
          onPressed: () async {
            await widget.missionService.restoreMission(deletedMission, deletedSubtasks);
            _loadData();
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );

    _loadData();
  }
}