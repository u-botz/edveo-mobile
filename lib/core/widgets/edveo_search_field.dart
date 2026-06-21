import 'package:flutter/material.dart';
import '../theme/edveo_colors.dart';
import '../theme/edveo_typography.dart';

class EdveoSearchField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  
  const EdveoSearchField({super.key, required this.onChanged});

  @override
  State<EdveoSearchField> createState() => _EdveoSearchFieldState();
}

class _EdveoSearchFieldState extends State<EdveoSearchField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      textField: true,
      label: 'Search institutions',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        height: 56,
        decoration: BoxDecoration(
          color: _isFocused ? EdveoColors.surface : EdveoColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isFocused ? EdveoColors.accentGreenRing : EdveoColors.divider,
            width: 1.5,
          ),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: EdveoColors.accentGreenSoft,
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 10),
              child: Icon(
                Icons.search_rounded,
                size: 20,
                color: EdveoColors.textSecondary,
              ),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: widget.onChanged,
                style: EdveoTypography.inputValue,
                cursorColor: EdveoColors.accentGreen,
                cursorWidth: 1.5,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search your institution...',
                  hintStyle: EdveoTypography.inputPlaceholder,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                textInputAction: TextInputAction.search,
              ),
            ),
            if (_controller.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _controller.clear();
                  widget.onChanged('');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: EdveoColors.textFaint,
                  ),
                ),
              )
            else
              const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
