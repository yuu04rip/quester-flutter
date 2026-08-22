// lib/widgets/edit_username_dialog.dart

import 'package:flutter/material.dart';
import '../utils/string_utils.dart';
import '/ui/theme/colors.dart';

/// Dialog per modificare username
class EditUsernameDialog extends StatefulWidget {
  final String currentUsername;
  final VoidCallback onDismiss;
  final Function(String) onConfirm;

  const EditUsernameDialog({
    super.key,
    required this.currentUsername,
    required this.onDismiss,
    required this.onConfirm,
  });

  @override
  State<EditUsernameDialog> createState() => _EditUsernameDialogState();
}

class _EditUsernameDialogState extends State<EditUsernameDialog> {
  late TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentUsername);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) {
      setState(() => _error = '✦ Il nome non può essere vuoto');
    } else if (trimmed.length < 3) {
      setState(() => _error = '✦ Minimo 3 caratteri');
    } else if (trimmed == widget.currentUsername) {
      widget.onDismiss();
    } else {
      widget.onConfirm(StringUtils.capitalizeFirstLetter(trimmed));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('✦ Cambia Nome', style: TextStyle(color: FantasyGoldLight)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Nuovo nome',
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onDismiss,
          child: const Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: _handleConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: FantasyGold,
            foregroundColor: const Color(0xFF0D0B14),
          ),
          child: const Text('Salva', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}