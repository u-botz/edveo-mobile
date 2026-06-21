import 'package:dio/dio.dart';
import 'package:edveo/core/api/api_client.dart';
import 'package:edveo/features/auth/data/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationPreferenceModel {
  final String category;
  final String channel;
  final bool enabled;
  final bool isMandatory;

  const NotificationPreferenceModel({
    required this.category,
    required this.channel,
    required this.enabled,
    required this.isMandatory,
  });

  factory NotificationPreferenceModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferenceModel(
      category: json['category'] as String,
      channel: json['channel'] as String,
      enabled: json['enabled'] as bool,
      isMandatory: json['is_mandatory'] as bool,
    );
  }

  Map<String, dynamic> toUpdateJson() => {
        'category': category,
        'channel': channel,
        'enabled': enabled,
      };
}

class NotificationPreferencesRepository {
  final Dio _dio;

  NotificationPreferencesRepository(ApiClient client) : _dio = client.dio;

  Future<List<NotificationPreferenceModel>> fetchPreferences() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/mobile/notifications/preferences',
    );
    final list = response.data!['data'] as List<dynamic>;
    return list
        .map((e) => NotificationPreferenceModel.fromJson(
              e as Map<String, dynamic>,
            ))
        .toList();
  }

  Future<void> updatePreferences(
    List<NotificationPreferenceModel> preferences,
  ) async {
    await _dio.put<Map<String, dynamic>>(
      '/api/mobile/notifications/preferences',
      data: {
        'preferences': preferences.map((p) => p.toUpdateJson()).toList(),
      },
    );
  }
}

final notificationPreferencesRepositoryProvider =
    Provider<NotificationPreferencesRepository>((ref) {
  return NotificationPreferencesRepository(ref.read(apiClientProvider));
});
