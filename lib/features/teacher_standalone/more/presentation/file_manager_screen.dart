import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:edveo/features/file_manager/data/models/managed_file_model.dart';
import 'file_manager_provider.dart';
import 'upload_picker_sheet.dart';
import 'delete_confirm_sheet.dart';

class FileManagerScreen extends ConsumerWidget {
  const FileManagerScreen({super.key});

  void _showUploadPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const UploadPickerSheet(),
    );
  }

  void _showDeleteConfirm(BuildContext context, ManagedFile file) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DeleteConfirmSheet(file: file),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fileManagerProvider);

    // Refresh list + quota after successful upload
    ref.listen<UploadState>(uploadProvider, (_, next) {
      if (next is UploadSuccess) {
        ref.read(fileManagerProvider.notifier).refresh();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('File Manager', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUploadPicker(context),
        icon: const Icon(Icons.upload_rounded),
        label: const Text('Upload'),
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          if (state.quota != null) _QuotaBar(quota: state.quota!),
          _UploadProgressBanner(),
          Expanded(child: _FileList(
            state:    state,
            onDelete: (file) => _showDeleteConfirm(context, file),
            onLoadMore: () => ref.read(fileManagerProvider.notifier).loadMore(),
            onRetry:    () => ref.read(fileManagerProvider.notifier).load(),
          )),
        ],
      ),
    );
  }
}

// ─── Quota bar ────────────────────────────────────────────────────────────────

class _QuotaBar extends StatelessWidget {
  final StorageQuota quota;
  const _QuotaBar({required this.quota});

  @override
  Widget build(BuildContext context) {
    final color = quota.isAtLimit
        ? Colors.red
        : quota.isNearLimit
            ? Colors.amber.shade700
            : const Color(0xFF059669);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${quota.usedFormatted} used',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Text(
                quota.totalFormatted,
                style: const TextStyle(fontSize: 12, color: Colors.black45),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: quota.fraction,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Upload progress banner ───────────────────────────────────────────────────

class _UploadProgressBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(uploadProvider);

    if (state is UploadIdle || state is UploadSuccess || state is UploadCancelled) {
      return const SizedBox.shrink();
    }

    if (state is UploadActive) {
      final pct = (state.progress * 100).toStringAsFixed(0);
      return Container(
        color: const Color(0xFFEFF6FF),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(
                value: state.progress,
                strokeWidth: 2,
                color: const Color(0xFF1D4ED8),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Uploading… $pct%',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF1D4ED8))),
            ),
            TextButton(
              onPressed: () => ref.read(uploadProvider.notifier).cancel(),
              child: const Text('Cancel', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
      );
    }

    if (state is UploadError) {
      return Container(
        color: const Color(0xFFFEF2F2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(state.message,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF991B1B))),
            ),
            if (!state.isQuotaExceeded)
              TextButton(
                onPressed: () => ref.read(uploadProvider.notifier).reset(),
                child: const Text('Dismiss', style: TextStyle(fontSize: 13)),
              ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

// ─── File list ────────────────────────────────────────────────────────────────

class _FileList extends StatelessWidget {
  final FileManagerState state;
  final void Function(ManagedFile) onDelete;
  final VoidCallback onLoadMore;
  final VoidCallback onRetry;

  const _FileList({
    required this.state,
    required this.onDelete,
    required this.onLoadMore,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (_, __) => _SkeletonCard(),
      );
    }

    if (state.error != null && state.files.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(state.error!, textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (state.files.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.folder_open_outlined, size: 64, color: Colors.black26),
              SizedBox(height: 16),
              Text('No files yet', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              SizedBox(height: 8),
              Text('Tap Upload to add your first file.',
                  style: TextStyle(color: Colors.black45)),
            ],
          ),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n is ScrollEndNotification &&
            n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
          onLoadMore();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        itemCount: state.files.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (_, i) {
          if (i == state.files.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final file = state.files[i];
          return _FileCard(file: file, onDelete: () => onDelete(file));
        },
      ),
    );
  }
}

// ─── File card ────────────────────────────────────────────────────────────────

class _FileCard extends StatelessWidget {
  final ManagedFile file;
  final VoidCallback onDelete;

  const _FileCard({required this.file, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('d MMM yyyy').format(file.createdAt.toLocal());

    return GestureDetector(
      onLongPress: onDelete,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            _FileThumbnail(file: file),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${file.sizeFormatted}  ·  $date',
                    style: const TextStyle(fontSize: 11, color: Colors.black45),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.black38, size: 20),
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}

class _FileThumbnail extends StatelessWidget {
  final ManagedFile file;
  const _FileThumbnail({required this.file});

  @override
  Widget build(BuildContext context) {
    if (file.fileType == ManagedFileType.image && file.previewUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          file.previewUrl!,
          width: 48, height: 48,
          fit: BoxFit.cover,
          // Decode at display resolution to avoid caching full-res in memory.
          cacheWidth: 96,   // 2× for high-DPI screens
          cacheHeight: 96,
          errorBuilder: (_, __, ___) => _iconBox(Icons.broken_image_outlined, Colors.grey),
        ),
      );
    }

    final (icon, color) = switch (file.fileType) {
      ManagedFileType.image    => (Icons.image_outlined, const Color(0xFF1D4ED8)),
      ManagedFileType.document => (Icons.picture_as_pdf_outlined, const Color(0xFFDC2626)),
      ManagedFileType.unknown  => (Icons.insert_drive_file_outlined, Colors.grey),
    };

    return _iconBox(icon, color);
  }

  Widget _iconBox(IconData icon, Color color) => Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: color, size: 24),
      );
}

// ─── Skeleton card ────────────────────────────────────────────────────────────

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      height: 68,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
