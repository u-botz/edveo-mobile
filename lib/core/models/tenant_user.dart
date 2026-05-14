class TenantUser {
  final String id;
  final String name;
  final String email;
  final String role;

  const TenantUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory TenantUser.fromJson(Map<String, dynamic> json) {
    return TenantUser(
      id: json['id'].toString(),
      name: '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim(),
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }
}
