class TenantBranding {
  final String name;
  final String city;
  final String? logoUrl;
  final String primaryColor;

  const TenantBranding({
    required this.name,
    required this.city,
    this.logoUrl,
    required this.primaryColor,
  });

  factory TenantBranding.fromJson(Map<String, dynamic> json) {
    return TenantBranding(
      name:         json['name'] as String,
      city:         json['city'] as String? ?? 'Unknown',
      logoUrl:      json['logo_url'] as String?,
      primaryColor: json['primary_color'] as String? ?? '#1A73E8',
    );
  }
}
