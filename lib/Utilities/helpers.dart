class Utils {
  static String formatDate(DateTime date) {
    final year = date.year;
    final month = _monthNames[date.month - 1];
    final day = date.day;
    //final hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    //final ampm = date.hour >= 12 ? 'PM' : 'AM';

    return '$day $month $year • ${date.hour.toString().padLeft(2, '0')}:${minute}';
  }

  static const List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
}
