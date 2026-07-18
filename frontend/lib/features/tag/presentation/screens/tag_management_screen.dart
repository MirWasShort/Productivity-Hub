import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/list_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../list/presentation/widgets/list_editor_dialog.dart';
import '../providers/tags_notifier.dart';

class TagManagementScreen extends ConsumerWidget {
  const TagManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(tagsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gestisci tag')),
      floatingActionButton: FloatingActionButton(
        key: const Key('tag_add'),
        onPressed: () => _createTag(context, ref),
        child: const Icon(Icons.add),
      ),
      body: tags.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.label_outline,
              title: 'Nessun tag',
              subtitle: 'Crea il primo tag con il pulsante +',
            );
          }
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: Dimens.sm),
            children: [
              for (final tag in items)
                ListTile(
                  key: Key('tag_row_${tag.id}'),
                  leading: CircleAvatar(
                      radius: 8, backgroundColor: colorFromHex(tag.color)),
                  title: Text(tag.name),
                  trailing: IconButton(
                    key: Key('tag_delete_${tag.id}'),
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () =>
                        ref.read(tagsProvider.notifier).deleteTag(tag.id),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _createTag(BuildContext context, WidgetRef ref) async {
    // Reuses the list editor dialog: same name + swatch shape.
    final result = await showDialog<ListEditorResult>(
      context: context,
      builder: (_) => const ListEditorDialog(),
    );
    if (result != null) {
      await ref
          .read(tagsProvider.notifier)
          .createTag(name: result.name, color: result.color);
    }
  }
}
