import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static String formatCurrency(double amount, {String symbol = '\$', int decimals = 2}) {
    final f = NumberFormat.currency(symbol: symbol, decimalDigits: decimals);
    return f.format(amount);
  }

  static String formatCompact(double amount) {
    if (amount >= 1000000) return '\$${(amount / 1000000).toStringAsFixed(2)}M';
    if (amount >= 1000) return '\$${(amount / 1000).toStringAsFixed(1)}K';
    return '\$${amount.toStringAsFixed(2)}';
  }

  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = today.difference(d).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return DateFormat('EEEE').format(date);
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
  }

  static String formatTime(DateTime date) => DateFormat('hh:mm a').format(date);

  static String formatShortDate(DateTime date) => DateFormat('MMM dd').format(date);

  static String formatMonthYear(DateTime date) => DateFormat('MMMM yyyy').format(date);

  static String maskAccountNumber(String n) {
    if (n.length < 4) return n;
    return '**** **** ${n.substring(n.length - 4)}';
  }

  static String maskCardNumber(String n) {
    if (n.length < 4) return n;
    return '**** **** **** ${n.substring(n.length - 4)}';
  }

  static String formatCardDisplay(String number) {
    final c = number.replaceAll(' ', '');
    final buf = StringBuffer();
    for (int i = 0; i < c.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(c[i]);
    }
    return buf.toString();
  }

  static String formatPercentage(double v, {int decimals = 1}) =>
      '${v.toStringAsFixed(decimals)}%';

  static String formatDuration(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return formatDate(date);
  }

  static String monthName(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[(m - 1).clamp(0, 11)];
  }
}
