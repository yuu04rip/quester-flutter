// lib/screens/mission_list_screen.dart

import 'package:flutter/material.dart';
import '/data/models/mission_with_subtasks.dart';
import '/repository/mission_repository.dart';
import '/repository/user_repository.dart';
import '/data/session/session_manager.dart';
import '/domain/service/mission_service.dart';
import '../mission/components/mission_card.dart';
import '../mission/components/filter_status.dart';
import '../mission/components/mission_list_header.dart';
import '../mission/components/mission_form_dialog.dart';
import '../mission/components/mission_detail_dialog.dart';

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

    // FIX: Se l'utente non è loggato, interrompiamo il caricamento per evitare il blocco perenne in loading
    if (userId == null) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      return;
    }

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

    final activeCount = _missions.where((m) => !m.mission.completed).length;

    return Column(
      children: [
        MissionListHeader(
          username: _username,
          activeMissionsCount: activeCount,
          onAddPressed: () => _showAddMissionDialog(context),
        ),
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
                onCompleteClick: () => _handleCompleteMission(context, missionWithTasks),
                onEditClick: () => _showEditMissionDialog(context, missionWithTasks),
                onResetClick: () => _showResetMissionDialog(context, missionWithTasks),
                onDeleteClick: () => _handleDeleteMission(context, missionWithTasks),
                onSubTaskToggled: (subTask, done) async {
                  await widget.missionService.toggleSubTask(subTask, done);
                  _loadData();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _handleCompleteMission(BuildContext context, MissionWithSubTasks missionWithTasks) async {
    final userId = await widget.sessionManager.loggedUserId();
    if (userId == null) return;

    if (!missionWithTasks.mission.completed) {
      await widget.missionService.completeMission(missionWithTasks.mission, userId);
      _loadData();
    }
  }

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
          Icon(icon, size: 14, color: isSelected ? theme.colorScheme.onSecondary : accentColor),
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
            child: Icon(Icons.shield_outlined, size: 48, color: accentColor.withValues(alpha: 0.7)),
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
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  void _showMissionDetail(BuildContext context, MissionWithSubTasks missionWithTasks) {
    showDialog(
      context: context,
      builder: (context) => MissionDetailDialog(
        missionWithTasks: missionWithTasks,
        missionService: widget.missionService,
        onSubTaskToggled: _loadData,
      ),
    );
  }

  void _showAddMissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => MissionFormDialog(
        title: 'Forgia Nuova Missione',
        confirmButtonText: 'Crea',
        onSubmit: (title, description, type, subtasks) async {
          await widget.missionService.createMissionFromForm(
            title: title,
            description: description,
            type: type,
            dueDate: null,
            subtasks: subtasks,
          );
          _loadData();
        },
      ),
    );
  }

  void _showEditMissionDialog(BuildContext context, MissionWithSubTasks missionWithTasks) {
    showDialog(
      context: context,
      builder: (context) => MissionFormDialog(
        title: 'Modifica Impresa',
        confirmButtonText: 'Salva',
        initialTitle: missionWithTasks.mission.title,
        initialDescription: missionWithTasks.mission.description,
        initialType: missionWithTasks.mission.type,
        initialSubtasks: missionWithTasks.subTasks.map((s) => s.text).toList(),
        onSubmit: (title, description, type, subtasks) async {
          await widget.missionService.updateMissionFromForm(
            mission: missionWithTasks.mission,
            newTitle: title,
            newDescription: description,
            newType: type,
            newSubtasksText: subtasks,
          );
          _loadData();
        },
      ),
    );
  }

  void _showResetMissionDialog(BuildContext context, MissionWithSubTasks missionWithTasks) {
    final missionId = missionWithTasks.mission.id;
    if (missionId == null) return;

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
              await widget.missionService.resetMission(missionId);
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
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    _loadData();
  }
}