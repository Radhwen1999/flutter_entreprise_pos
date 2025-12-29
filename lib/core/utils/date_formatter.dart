import 'package:intl/intl.dart';

/// Date and time formatting utilities
class DateFormatter {
  DateFormatter._();

  // ═══════════════════════════════════════════════════════════════
  // DATE FORMATTERS
  // ═══════════════════════════════════════════════════════════════
  
  static final DateFormat _fullDate = DateFormat('MMMM d, yyyy');
  static final DateFormat _shortDate = DateFormat('MMM d, yyyy');
  static final DateFormat _numericDate = DateFormat('MM/dd/yyyy');
  static final DateFormat _isoDate = DateFormat('yyyy-MM-dd');
  
  // ═══════════════════════════════════════════════════════════════
  // TIME FORMATTERS
  // ═══════════════════════════════════════════════════════════════
  
  static final DateFormat _time12h = DateFormat('h:mm a');
  static final DateFormat _time24h = DateFormat('HH:mm');
  static final DateFormat _timeWithSeconds = DateFormat('HH:mm:ss');
  
  // ═══════════════════════════════════════════════════════════════
  // DATETIME FORMATTERS
  // ═══════════════════════════════════════════════════════════════
  
  static final DateFormat _fullDateTime = DateFormat('MMMM d, yyyy h:mm a');
  static final DateFormat _shortDateTime = DateFormat('MMM d, h:mm a');
  static final DateFormat _compactDateTime = DateFormat('MM/dd/yy HH:mm');
  
  // ═══════════════════════════════════════════════════════════════
  // FORMAT METHODS
  // ═══════════════════════════════════════════════════════════════
  
  static String fullDate(DateTime date) => _fullDate.format(date);
  static String shortDate(DateTime date) => _shortDate.format(date);
  static String numericDate(DateTime date) => _numericDate.format(date);
  static String isoDate(DateTime date) => _isoDate.format(date);
  
  static String time12h(DateTime date) => _time12h.format(date);
  static String time24h(DateTime date) => _time24h.format(date);
  static String timeWithSeconds(DateTime date) => _timeWithSeconds.format(date);
  
  static String fullDateTime(DateTime date) => _fullDateTime.format(date);
  static String shortDateTime(DateTime date) => _shortDateTime.format(date);
  static String compactDateTime(DateTime date) => _compactDateTime.format(date);

  // ═══════════════════════════════════════════════════════════════
  // RELATIVE TIME
  // ═══════════════════════════════════════════════════════════════
  
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // SMART DATE
  // ═══════════════════════════════════════════════════════════════
  
  static String smartDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today, ${time12h(date)}';
    } else if (dateOnly == yesterday) {
      return 'Yesterday, ${time12h(date)}';
    } else if (now.difference(date).inDays < 7) {
      return '${DateFormat('EEEE').format(date)}, ${time12h(date)}';
    } else {
      return shortDateTime(date);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // DAY OF WEEK
  // ═══════════════════════════════════════════════════════════════
  
  static String dayOfWeek(DateTime date) => DateFormat('EEEE').format(date);
  static String shortDayOfWeek(DateTime date) => DateFormat('EEE').format(date);
  
  // ═══════════════════════════════════════════════════════════════
  // MONTH
  // ═══════════════════════════════════════════════════════════════
  
  static String monthName(DateTime date) => DateFormat('MMMM').format(date);
  static String shortMonthName(DateTime date) => DateFormat('MMM').format(date);
  static String monthYear(DateTime date) => DateFormat('MMMM yyyy').format(date);
}
