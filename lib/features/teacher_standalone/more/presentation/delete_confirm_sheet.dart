import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edveo/features/file_manager/data/models/managed_file_model.dart';
import 'file_manager_provider.dart';

class DeleteConfirmSheet extends ConsumerWidget {
  final ManagedFile file;

  const DeleteConfirmSheet({super.key, required this.file});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<DeleteState>(deleteProvider, (_, next) {
      if (next is DeleteSuccess) {
        Navigator.of(context).pop();
        ref.read(fileManagerProvider.notifier).removeFile(file.id);
      }
    });

    final state     = ref.watch(deleteProvider);
    final isLoading = state is DeleteLoading;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Delete file?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              file.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            const Text(
              'This will permanently delete the file. This cannot be undone.',
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
            if (state is DeleteError) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Text(
                  state.message,
                  style: const TextStyle(color: Color(0xFF991B1B), fontSize: 13),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () => ref.read(deleteProvider.notifier).delete(file.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 18, width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
