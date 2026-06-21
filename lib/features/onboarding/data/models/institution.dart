class Institution {
  const Institution({
    required this.slug,
    required this.name,
    this.city,
    this.logoUrl,
  });

  final String slug;
  final String name;
  final String? city;
  final String? logoUrl;

  factory Institution.fromJson(Map<String, dynamic> json) {
    return Institution(
      slug: json['slug'] as String,
      name: json['name'] as String,
      city: json['city'] as String?,
      logoUrl: json['logo_url'] as String?,
    );
  }

  String get initials {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return words[0][0].toUpperCase();
  }
}
