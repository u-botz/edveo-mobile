/// Formats whole-rupee integers (price_amount, fees) with Indian comma style.
/// 1499 → ₹1,499
/// 100000 → ₹1,00,000
/// Use this for course prices. For cents fields use formatCurrency() instead.
String formatRupees(int rupees) {
  if (rupees == 0) return '₹0';

  final str = rupees.toString();
  if (str.length <= 3) return '₹$str';

  // Indian numbering: last 3 digits, then every 2 digits
  final lastThree = str.substring(str.length - 3);
  final rest = str.substring(0, str.length - 3);
  final restFormatted = rest.replaceAllMapped(
    RegExp(r'(\d)(?=(\d\d)+$)'),
    (m) => '${m[1]},',
  );

  return '₹$restFormatted,$lastThree';
}
