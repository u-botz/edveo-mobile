class StudentFeesDueModel {
  final bool hasDues;
  final NextDueModel? nextDue;

  const StudentFeesDueModel({required this.hasDues, this.nextDue});

  factory StudentFeesDueModel.fromJson(Map<String, dynamic> json) {
    final raw = json['next_due'];
    return StudentFeesDueModel(
      hasDues: json['has_dues'] as bool,
      nextDue: raw != null
          ? NextDueModel.fromJson(raw as Map<String, dynamic>)
          : null,
    );
  }
}

class NextDueModel {
  final String amountFormatted; // "₹12,000"
  final String dueDateLabel;    // "15 Jun 2026"
  final String termLabel;       // "Instalment 2 of 4"
  final bool isOverdue;

  const NextDueModel({
    required this.amountFormatted,
    required this.dueDateLabel,
    required this.termLabel,
    required this.isOverdue,
  });

  factory NextDueModel.fromJson(Map<String, dynamic> json) {
    return NextDueModel(
      amountFormatted: json['amount_formatted'] as String,
      dueDateLabel:    json['due_date_label'] as String,
      termLabel:       json['term_label'] as String,
      isOverdue:       json['is_overdue'] as bool,
    );
  }

  // e.g. "Pay before 15 Jun 2026" or "OVERDUE · 15 Jun 2026"
  String get dueDateDisplay =>
      isOverdue ? 'OVERDUE · $dueDateLabel' : 'Due $dueDateLabel';
}
