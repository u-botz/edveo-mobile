enum LiveSessionProvider {
  zoom,
  agora,
  jitsi,
  googleMeet,
  bigBlueButton,
  youtube,
  local,
  unknown;

  static LiveSessionProvider fromString(String value) => switch (value) {
        'zoom'            => zoom,
        'agora'           => agora,
        'jitsi'           => jitsi,
        'google_meet'     => googleMeet,
        'big_blue_button' => bigBlueButton,
        'youtube'         => youtube,
        'local'           => local,
        _                 => unknown,
      };

  String get displayLabel => switch (this) {
        zoom          => 'VIA ZOOM',
        agora         => 'VIA AGORA',
        jitsi         => 'VIA JITSI',
        googleMeet    => 'VIA GOOGLE MEET',
        bigBlueButton => 'VIA BIG BLUE BUTTON',
        youtube       => 'VIA YOUTUBE LIVE',
        local         => 'VIA CUSTOM LINK',
        unknown       => 'LIVE SESSION',
      };
}

enum LiveSessionOperationalStatus {
  pending,
  liveNow,
  ended,
  unknown;

  static LiveSessionOperationalStatus fromString(String value) => switch (value) {
        'pending'  => pending,
        'live_now' => liveNow,
        'ended'    => ended,
        _          => unknown,
      };
}

class NextLiveSession {
  final int id;
  final String title;
  final String? description;
  final LiveSessionProvider provider;
  final DateTime date;
  final int durationMinutes;
  final String? startLink;
  final LiveSessionOperationalStatus operationalStatus;
  final int minutesUntilStart;
  final String? courseTitle;
  final int enrolledStudentsCount;

  const NextLiveSession({
    required this.id,
    required this.title,
    this.description,
    required this.provider,
    required this.date,
    required this.durationMinutes,
    this.startLink,
    required this.operationalStatus,
    required this.minutesUntilStart,
    this.courseTitle,
    required this.enrolledStudentsCount,
  });

  DateTime get endTime => date.add(Duration(minutes: durationMinutes));

  bool get canStart =>
      startLink != null &&
      startLink!.isNotEmpty &&
      operationalStatus != LiveSessionOperationalStatus.ended;

  factory NextLiveSession.fromJson(Map<String, dynamic> json) => NextLiveSession(
        id: json['id'] as int,
        title: json['title'] as String,
        description: json['description'] as String?,
        provider: LiveSessionProvider.fromString(json['provider'] as String),
        date: DateTime.parse(json['date'] as String),
        durationMinutes: json['duration_minutes'] as int,
        startLink: json['start_link'] as String?,
        operationalStatus: LiveSessionOperationalStatus.fromString(
            json['operational_status'] as String),
        minutesUntilStart: json['minutes_until_start'] as int,
        courseTitle: json['course_title'] as String?,
        enrolledStudentsCount: json['enrolled_students_count'] as int,
      );
}

class RecentLiveSession {
  final int id;
  final String title;
  final LiveSessionProvider provider;
  final DateTime date;
  final int durationMinutes;

  const RecentLiveSession({
    required this.id,
    required this.title,
    required this.provider,
    required this.date,
    required this.durationMinutes,
  });

  factory RecentLiveSession.fromJson(Map<String, dynamic> json) =>
      RecentLiveSession(
        id: json['id'] as int,
        title: json['title'] as String,
        provider: LiveSessionProvider.fromString(json['provider'] as String),
        date: DateTime.parse(json['date'] as String),
        durationMinutes: json['duration_minutes'] as int,
      );
}

class LiveSessionTodayResponse {
  final NextLiveSession? nextSession;
  final List<RecentLiveSession> recentSessions;

  const LiveSessionTodayResponse({
    this.nextSession,
    required this.recentSessions,
  });

  bool get hasSession => nextSession != null;
  bool get hasRecentSessions => recentSessions.isNotEmpty;
}
