import 'package:flutter/material.dart';

import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/list_colors.dart';

/// Result of the list create/edit dialog.
typedef ListEditorResult = ({String name, String color});

/// Name field + eight preset color swatches. Returns null on cancel.
class ListEditorDialog extends StatefulWidget {
  const ListEditorDialog({super.key, this.initialName, this.initialColor});

  final String? initialName;
  final String? initialColor;

  @override
  State<ListEditorDialog> createState() => _ListEditorDialogState();
}

class _ListEditorDialogState extends State<ListEditorDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialName);
  late String _color = widget.initialColor ?? listColorSwatches.first;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      return;
    }
    Navigator.of(context).pop((name: name, color: _color));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialName == null ? 'Nuova lista' : 'Rinomina lista'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: const Key('list_name'),
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Nome'),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: Dimens.lg),
          Wrap(
            spacing: Dimens.sm,
            children: [
              for (final swatch in listColorSwatches)
                GestureDetector(
                  key: Key('list_color_$swatch'),
                  onTap: () => setState(() => _color = swatch),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: colorFromHex(swatch),
                    child: _color == swatch
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        FilledButton(
          key: const Key('list_save'),
          onPressed: _submit,
          child: const Text('Salva'),
        ),
      ],
    );
  }
}
