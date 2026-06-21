import 'package:edveo/features/auth/data/models/me_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Populated once after `/api/mobile/auth/me` during role routing.
/// More page reads this — no extra `/me` call.
final currentMeProvider = StateProvider<MeModel?>((ref) => null);
