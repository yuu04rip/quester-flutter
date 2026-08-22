// lib/widgets/delete_account_dialog.dart

import 'package:flutter/material.dart';
import '/ui/theme/colors.dart';

/// Dialog per eliminare account
class DeleteAccountDialog extends StatefulWidget {
  final VoidCallback onDismiss;
  final VoidCallback onConfirm;

  const DeleteAccountDialog({
    super.key,
    required this.onDismiss,
    required this.onConfirm,
  });

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Lascia il Regno', style: TextStyle(color: FantasyError)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Questa scelta è PERMANENTE e non può essere annullata.'),
          const Text('Per confermare, digita il tuo nome:'),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Il tuo nome',
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onDismiss,
          child: const Text('Torna indietro', style: TextStyle(color: FantasyGoldLight)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.trim().isEmpty) {
              setState(() => _error = '✦ Scrivi il tuo nome per confermare');
            } else {
              widget.onConfirm();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: FantasyError,
            foregroundColor: FantasyText,
          ),
          child: const Text('Abbandona il Regno', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}