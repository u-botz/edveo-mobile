enum BannerVariant { alert, briefing, tip }
enum BannerSeverity { info, success, warning }

class AiBannerModel {
  final BannerVariant variant;
  final String badge;
  final String headline;
  final String body;
  final String? ctaLabel;
  final String? ctaRoute;
  final BannerSeverity severity;

  const AiBannerModel({
    required this.variant,
    required this.badge,
    required this.headline,
    required this.body,
    this.ctaLabel,
    this.ctaRoute,
    required this.severity,
  });

  factory AiBannerModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return AiBannerModel(
      variant:  _parseVariant(data['variant'] as String),
      badge:    data['badge'] as String,
      headline: data['headline'] as String,
      body:     data['body'] as String,
      ctaLabel: data['cta_label'] as String?,
      ctaRoute: data['cta_route'] as String?,
      severity: _parseSeverity(data['severity'] as String),
    );
  }

  static BannerVariant _parseVariant(String v) => switch (v) {
    'alert'    => BannerVariant.alert,
    'briefing' => BannerVariant.briefing,
    _          => BannerVariant.tip,
  };

  static BannerSeverity _parseSeverity(String v) => switch (v) {
    'success' => BannerSeverity.success,
    'warning' => BannerSeverity.warning,
    _         => BannerSeverity.info,
  };

  /// Local fallback if the endpoint fails entirely.
  /// Backend already guarantees a tip on success — this is only for network failure.
  factory AiBannerModel.fallback() => const AiBannerModel(
    variant:  BannerVariant.tip,
    badge:    "TODAY'S SNAPSHOT",
    headline: 'Welcome back',
    body:     'Your dashboard is ready. Take a look at what students are up to.',
    severity: BannerSeverity.info,
  );
}
