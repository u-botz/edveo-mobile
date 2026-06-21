/// Authenticated session identity from `GET /api/mobile/auth/me`.
///
/// Lives under [features/auth] because it is produced by the auth/session flow
/// and consumed by all three shells (student, institutional, standalone) via
/// [currentMeProvider] — not a standalone-teacher domain model.
class MeTenantModel {
  final int id;
  final String name;
  final String slug;
  final String tenantCategory;

  const MeTenantModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.tenantCategory,
  });

  factory MeTenantModel.fromJson(Map<String, dynamic> json) {
    return MeTenantModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      tenantCategory: json['tenant_category'] as String? ?? '',
    );
  }
}

class MeSubscriptionModel {
  final String status;
  final String? planName;
  final String? planSlug;

  const MeSubscriptionModel({
    required this.status,
    this.planName,
    this.planSlug,
  });

  factory MeSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return MeSubscriptionModel(
      status: json['status'] as String,
      planName: json['plan_name'] as String?,
      planSlug: json['plan_slug'] as String?,
    );
  }
}

class MeModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final MeTenantModel tenant;
  final MeSubscriptionModel? subscription;
  /// Flat list of capability slugs granted to this user, e.g. ['blog.manage', 'quiz.view'].
  /// Sourced from the `capabilities` array in `GET /api/mobile/auth/me`.
  final List<String> capabilities;

  const MeModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.tenant,
    this.subscription,
    this.capabilities = const [],
  });

  String get displayName {
    final full = '$firstName $lastName'.trim();
    return full.isNotEmpty ? full : email;
  }

  String get initials {
    final first = firstName.trim();
    final last = lastName.trim();
    if (first.isNotEmpty && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    }
    if (first.isNotEmpty) {
      return first.length >= 2
          ? first.substring(0, 2).toUpperCase()
          : first[0].toUpperCase();
    }
    if (email.isNotEmpty) return email[0].toUpperCase();
    return '?';
  }

  /// Returns true when this user has the given capability slug.
  bool hasCapability(String capability) => capabilities.contains(capability);

  factory MeModel.fromJson(Map<String, dynamic> json) {
    final subscriptionJson = json['subscription'];
    final rawCaps = json['capabilities'];
    final capabilities = rawCaps is List
        ? rawCaps.whereType<String>().toList()
        : const <String>[];

    return MeModel(
      id: json['id'].toString(),
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      email: json['email'] as String,
      role: json['role'] as String,
      tenant: MeTenantModel.fromJson(
        json['tenant'] as Map<String, dynamic>,
      ),
      subscription: subscriptionJson is Map<String, dynamic>
          ? MeSubscriptionModel.fromJson(subscriptionJson)
          : null,
      capabilities: capabilities,
    );
  }
}
