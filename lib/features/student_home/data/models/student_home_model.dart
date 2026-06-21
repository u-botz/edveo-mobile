import 'continue_learning_item_model.dart';
import 'notice_model.dart';
import 'student_home_live_session_model.dart';

class StudentHomeModel {
  final StudentHomeLiveSessionModel? nextLiveSession;
  final List<ContinueLearningItemModel> continueLearning;
  final NoticeModel? recentNotice;

  const StudentHomeModel({
    this.nextLiveSession,
    required this.continueLearning,
    this.recentNotice,
  });

  factory StudentHomeModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;

    final rawSession = data['next_live_session'] as Map<String, dynamic>?;
    final rawContinue = data['continue_learning'] as List<dynamic>? ?? [];
    final rawNotice = data['recent_notice'] as Map<String, dynamic>?;

    return StudentHomeModel(
      nextLiveSession: rawSession != null
          ? StudentHomeLiveSessionModel.fromJson(rawSession)
          : null,
      continueLearning: rawContinue
          .map((e) => ContinueLearningItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentNotice: rawNotice != null
          ? NoticeModel.fromJson(rawNotice)
          : null,
    );
  }
}
