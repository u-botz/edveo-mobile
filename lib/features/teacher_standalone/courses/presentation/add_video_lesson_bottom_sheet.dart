import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'course_manage_provider.dart';

class AddVideoLessonBottomSheet extends ConsumerStatefulWidget {
  final int courseId;
  final int chapterId;
  final int? subjectId; // null in chapter_lesson mode

  const AddVideoLessonBottomSheet({
    super.key,
    required this.courseId,
    required this.chapterId,
    this.subjectId,
  });

  @override
  ConsumerState<AddVideoLessonBottomSheet> createState() => _AddVideoLessonBottomSheetState();
}

class _AddVideoLessonBottomSheetState extends ConsumerState<AddVideoLessonBottomSheet> {
  final _formKey    = GlobalKey<FormState>();
  final _titleCtrl  = TextEditingController();
  final _urlCtrl    = TextEditingController();
  String? _urlError;
  bool _loading     = false;
  String? _error;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  TextStyle _pjs({double size = 13, FontWeight weight = FontWeight.w400, Color color = const Color(0xFF111827)}) =>
      GoogleFonts.plusJakartaSans(fontSize: size, fontWeight: weight, color: color);

  Future<void> _submit() async {
    setState(() => _urlError = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    final err = await ref.read(courseManageProvider(widget.courseId).notifier).addVideoLesson(
      widget.chapterId,
      _titleCtrl.text.trim(),
      _urlCtrl.text.trim(),
      subjectId: widget.subjectId,
    );
    if (!mounted) return;
    if (err == null) {
      Navigator.of(context).pop();
    } else {
      // Surface video_url field errors inline; others as banner
      setState(() {
        _loading = false;
        if (err.toLowerCase().contains('url') || err.toLowerCase().contains('video')) {
          _urlError = err;
        } else {
          _error = err;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),
            Text('Add Video Lesson', style: _pjs(size: 18, weight: FontWeight.w700)),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleCtrl,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Lesson title'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Lesson title is required' : null,
              enabled: !_loading,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _urlCtrl,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.url,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: 'YouTube or Vimeo URL',
                hintText: 'https://youtu.be/...',
                errorText: _urlError,
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Video URL is required' : null,
              enabled: !_loading,
              onFieldSubmitted: (_) { if (!_loading) _submit(); },
            ),
            const SizedBox(height: 20),
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Text(_error!, style: _pjs(size: 13, color: const Color(0xFF991B1B))),
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D4ED8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Add Lesson', style: _pjs(size: 14, weight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
