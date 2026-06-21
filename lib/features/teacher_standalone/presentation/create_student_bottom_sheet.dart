import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edveo/features/students/data/models/create_student_request.dart';
import 'package:edveo/features/teacher_standalone/presentation/create_student_provider.dart';
import 'package:edveo/features/teacher_standalone/presentation/students_provider.dart';

class CreateStudentBottomSheet extends ConsumerStatefulWidget {
  const CreateStudentBottomSheet({super.key});

  @override
  ConsumerState<CreateStudentBottomSheet> createState() =>
      _CreateStudentBottomSheetState();
}

class _CreateStudentBottomSheetState
    extends ConsumerState<CreateStudentBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final request = CreateStudentRequest(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim().toLowerCase(),
      password: _passwordController.text,
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
    );
    ref.read(createStudentProvider.notifier).submit(request);
  }

  TextStyle _pjs({
    double size = 13,
    FontWeight weight = FontWeight.w400,
    Color color = const Color(0xFF111827),
  }) =>
      GoogleFonts.plusJakartaSans(
          fontSize: size, fontWeight: weight, color: color);

  @override
  Widget build(BuildContext context) {
    ref.listen<CreateStudentState>(createStudentProvider, (_, next) {
      if (next is CreateStudentSuccess) {
        // BR-CS-010: close sheet then refresh list so new student appears at top
        Navigator.of(context).pop();
        ref.read(studentsNotifierProvider.notifier).refresh();
      }
    });

    final state = ref.watch(createStudentProvider);
    final isLoading = state is CreateStudentLoading;

    final emailBackendError =
        (state is CreateStudentError && state.field == 'email')
            ? state.message
            : null;

    final genericError =
        (state is CreateStudentError && state.field == null)
            ? state.message
            : null;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            Text('Add Student',
                style: _pjs(size: 18, weight: FontWeight.w700)),
            const SizedBox(height: 20),

            // First name
            TextFormField(
              controller: _firstNameController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'First name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'First name is required' : null,
              enabled: !isLoading,
            ),
            const SizedBox(height: 12),

            // Last name
            TextFormField(
              controller: _lastNameController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Last name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Last name is required' : null,
              enabled: !isLoading,
            ),
            const SizedBox(height: 12),

            // Email — shows backend duplicate error inline on the field
            TextFormField(
              controller: _emailController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: emailBackendError,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!v.contains('@') || !v.contains('.')) {
                  return 'Enter a valid email';
                }
                return null;
              },
              enabled: !isLoading,
            ),
            const SizedBox(height: 12),

            // Password
            TextFormField(
              controller: _passwordController,
              textInputAction: TextInputAction.next,
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: isLoading
                      ? null
                      : () => setState(
                          () => _passwordVisible = !_passwordVisible),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 8) return 'Password must be at least 8 characters';
                return null;
              },
              enabled: !isLoading,
            ),
            const SizedBox(height: 12),

            // Phone (optional)
            TextFormField(
              controller: _phoneController,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone (optional)',
                hintText: '+91 98765 43210',
              ),
              onFieldSubmitted: (_) {
                if (!isLoading) _submit();
              },
              enabled: !isLoading,
            ),
            const SizedBox(height: 20),

            // Generic error banner (network failure, unexpected errors)
            if (genericError != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Text(
                  genericError,
                  style: _pjs(size: 13, color: const Color(0xFF991B1B)),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Submit button
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D4ED8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text('Add Student',
                        style: _pjs(
                            size: 14,
                            weight: FontWeight.w600,
                            color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
