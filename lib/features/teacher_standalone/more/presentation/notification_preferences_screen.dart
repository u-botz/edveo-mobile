import 'package:edveo/features/notifications/data/notification_preferences_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  ConsumerState<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends ConsumerState<NotificationPreferencesScreen> {
  List<NotificationPreferenceModel>? _prefs;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final prefs = await ref
          .read(notificationPreferencesRepositoryProvider)
          .fetchPreferences();
      if (mounted) {
        setState(() {
          _prefs = prefs;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Could not load notification preferences.';
        });
      }
    }
  }

  Future<void> _toggle(int index, bool value) async {
    final prefs = _prefs;
    if (prefs == null || prefs[index].isMandatory) return;

    final updated = List<NotificationPreferenceModel>.from(prefs);
    updated[index] = NotificationPreferenceModel(
      category: prefs[index].category,
      channel: prefs[index].channel,
      enabled: value,
      isMandatory: prefs[index].isMandatory,
    );
    setState(() {
      _prefs = updated;
      _saving = true;
    });

    try {
      await ref
          .read(notificationPreferencesRepositoryProvider)
          .updatePreferences(updated);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save preference')),
        );
        await _load();
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _labelFor(String category) {
    return switch (category) {
      'billing' => 'Billing',
      'security' => 'Security',
      'system' => 'System',
      _ => category,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        title: Text(
          'Notifications',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: GoogleFonts.plusJakartaSans(color: Colors.red),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _prefs!.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final pref = _prefs![index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: SwitchListTile(
                        title: Text(
                          _labelFor(pref.category),
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: pref.isMandatory
                            ? Text(
                                'Required',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: const Color(0xFF6B7280),
                                ),
                              )
                            : null,
                        value: pref.enabled,
                        onChanged: _saving || pref.isMandatory
                            ? null
                            : (v) => _toggle(index, v),
                      ),
                    );
                  },
                ),
    );
  }
}
