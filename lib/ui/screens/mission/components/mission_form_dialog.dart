// lib/screens/mission/components/mission_form_dialog.dart

import 'package:flutter/material.dart';

class MissionFormDialog extends StatefulWidget {
  final String title;
  final String confirmButtonText;
  final String initialTitle;
  final String initialDescription;
  final String initialType;
  final List<String> initialSubtasks;
  final Function(String title, String description, String type, List<String> subtasks) onSubmit;

  const MissionFormDialog({
    super.key,
    required this.title,
    required this.confirmButtonText,
    this.initialTitle = '',
    this.initialDescription = '',
    this.initialType = 'GIORNALIERO',
    this.initialSubtasks = const [],
    required this.onSubmit,
  });

  @override
  State<MissionFormDialog> createState() => _MissionFormDialogState();
}

class _MissionFormDialogState extends State<MissionFormDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  final TextEditingController _subtaskController = TextEditingController();
  late String _selectedType;
  late List<String> _subtasksList;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController = TextEditingController(text: widget.initialDescription);
    _selectedType = widget.initialType;
    _subtasksList = List.from(widget.initialSubtasks);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  void _addSubtask() {
    final text = _subtaskController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _subtasksList.add(text);
        _subtaskController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.secondary;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titolo dell\'impresa',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Descrizione (opzionale)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _selectedType,
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
                    setState(() => _selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 20),
              const Text('Sotto-attività (Subtasks)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _subtaskController,
                      decoration: const InputDecoration(
                        labelText: 'Aggiungi subtask...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _addSubtask(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _addSubtask,
                    icon: const Icon(Icons.add, size: 18),
                    style: IconButton.styleFrom(backgroundColor: accentColor),
                  ),
                ],
              ),
              if (_subtasksList.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _subtasksList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.subdirectory_arrow_right_rounded, size: 14, color: Colors.grey),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(_subtasksList[index], style: const TextStyle(fontSize: 13)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 16, color: Colors.redAccent),
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                setState(() {
                                  _subtasksList.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.trim().isNotEmpty) {
              widget.onSubmit(
                _titleController.text.trim(),
                _descriptionController.text.trim(),
                _selectedType,
                _subtasksList,
              );
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: theme.colorScheme.onSecondary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(widget.confirmButtonText, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}