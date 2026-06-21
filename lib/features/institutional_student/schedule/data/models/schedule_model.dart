class ScheduleBatchModel {
  final int id;
  final String name;
  final String code;

  const ScheduleBatchModel({
    required this.id,
    required this.name,
    required this.code,
  });

  factory ScheduleBatchModel.fromJson(Map<String, dynamic> j) =>
      ScheduleBatchModel(
        id: j['id'] as int,
        name: j['name'] as String? ?? '',
        code: j['code'] as String? ?? '',
      );
}

class ScheduleTemplateModel {
  final int id;
  final String title;
  final String status;

  const ScheduleTemplateModel({
    required this.id,
    required this.title,
    required this.status,
  });

  factory ScheduleTemplateModel.fromJson(Map<String, dynamic> j) =>
      ScheduleTemplateModel(
        id: j['id'] as int,
        title: j['title'] as String? ?? '',
        status: j['status'] as String? ?? '',
      );
}

class ScheduleSlotModel {
  final int id;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final String? subject;
  final String? teacher;
  final String? venue;
  final String sessionType;
  final String? label;      // title_override — custom display name
  final bool isOptional;
  final int sortOrder;

  const ScheduleSlotModel({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.subject,
    this.teacher,
    this.venue,
    required this.sessionType,
    this.label,
    required this.isOptional,
    required this.sortOrder,
  });

  String get displayName => label?.isNotEmpty == true ? label! : subject ?? 'Class';

  factory ScheduleSlotModel.fromJson(Map<String, dynamic> j) =>
      ScheduleSlotModel(
        id:          j['id'] as int,
        dayOfWeek:   j['day_of_week'] as int,
        startTime:   j['start_time'] as String? ?? '',
        endTime:     j['end_time'] as String? ?? '',
        subject:     j['subject'] as String?,
        teacher:     j['teacher'] as String?,
        venue:       j['venue'] as String?,
        sessionType: j['session_type'] as String? ?? 'offline_class',
        label:       j['label'] as String?,
        isOptional:  j['is_optional'] as bool? ?? false,
        sortOrder:   j['sort_order'] as int? ?? 0,
      );
}

class StudentScheduleModel {
  final ScheduleBatchModel batch;
  final ScheduleTemplateModel template;
  final List<int> workingDays;
  final List<ScheduleSlotModel> slots;

  const StudentScheduleModel({
    required this.batch,
    required this.template,
    required this.workingDays,
    required this.slots,
  });

  List<ScheduleSlotModel> slotsForDay(int dayOfWeek) =>
      slots.where((s) => s.dayOfWeek == dayOfWeek).toList();

  factory StudentScheduleModel.fromJson(Map<String, dynamic> j) {
    final rawDays = j['working_days'] as List<dynamic>? ?? [];
    final rawSlots = j['slots'] as List<dynamic>? ?? [];

    return StudentScheduleModel(
      batch:       ScheduleBatchModel.fromJson(j['batch'] as Map<String, dynamic>),
      template:    ScheduleTemplateModel.fromJson(j['template'] as Map<String, dynamic>),
      workingDays: rawDays.whereType<int>().toList(),
      slots:       rawSlots
          .whereType<Map<String, dynamic>>()
          .map(ScheduleSlotModel.fromJson)
          .toList(),
    );
  }
}
