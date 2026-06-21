import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'file_manager_provider.dart';

class UploadPickerSheet extends ConsumerWidget {
  const UploadPickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_outlined),
              title: const Text('Photo'),
              subtitle: const Text('JPEG, PNG, WebP or GIF · max 5 MB'),
              onTap: () => _pickImage(context, ref),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: const Text('Document'),
              subtitle: const Text('PDF only · max 20 MB'),
              onTap: () => _pickDocument(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file      = File(picked.path);
    final sizeBytes = await file.length();

    if (sizeBytes > 5 * 1024 * 1024) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image must be under 5 MB.')),
        );
      }
      return;
    }

    if (context.mounted) Navigator.of(context).pop();

    await ref.read(uploadProvider.notifier).upload(
      file:     file,
      mimeType: picked.mimeType ?? 'image/jpeg',
    );
  }

  Future<void> _pickDocument(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type:             FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple:    false,
    );

    if (result == null || result.files.single.path == null) return;

    final file      = File(result.files.single.path!);
    final sizeBytes = await file.length();

    if (sizeBytes > 20 * 1024 * 1024) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF must be under 20 MB.')),
        );
      }
      return;
    }

    if (context.mounted) Navigator.of(context).pop();

    await ref.read(uploadProvider.notifier).upload(
      file:     file,
      mimeType: 'application/pdf',
    );
  }
}
