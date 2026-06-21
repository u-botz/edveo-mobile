class MoreSummaryModel {
  final int aiCreditsRemaining;
  final int blogPublishedCount;
  final int monthlyEarningsCents;
  final int meetingsBookedToday;
  final String planLabel;
  final bool showUpgradeBanner;

  const MoreSummaryModel({
    required this.aiCreditsRemaining,
    required this.blogPublishedCount,
    required this.monthlyEarningsCents,
    required this.meetingsBookedToday,
    required this.planLabel,
    required this.showUpgradeBanner,
  });

  factory MoreSummaryModel.fromJson(Map<String, dynamic> json) {
    return MoreSummaryModel(
      aiCreditsRemaining: json['ai_credits_remaining'] as int,
      blogPublishedCount: json['blog_published_count'] as int,
      monthlyEarningsCents: json['monthly_earnings_cents'] as int,
      meetingsBookedToday: json['meetings_booked_today'] as int,
      planLabel: json['plan_label'] as String,
      showUpgradeBanner: json['show_upgrade_banner'] as bool,
    );
  }
}
