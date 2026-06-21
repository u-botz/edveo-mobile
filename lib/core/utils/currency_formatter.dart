String formatCurrency(int cents) {
  final rupees = cents / 100;
  if (rupees >= 100000) {
    return '₹${(rupees / 100000).toStringAsFixed(1)}L';
  }
  if (rupees >= 1000) {
    return '₹${(rupees / 1000).toStringAsFixed(1)}K';
  }
  return '₹${rupees.toStringAsFixed(0)}';
}
