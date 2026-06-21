import 'package:intl/intl.dart';

/// Whole rupees from cents (integer division). Never show raw cents in UI.
String formatMonthlyEarnings(int monthlyEarningsCents) {
  final rupees = monthlyEarningsCents ~/ 100;
  final formatted = NumberFormat.decimalPattern('en_IN').format(rupees);
  return '₹$formatted this month';
}
