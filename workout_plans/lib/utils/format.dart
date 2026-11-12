const List<String> _months = [
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

String _two(int value) => value.toString().padLeft(2, '0');

String formatTime(int hour, int minute) => '${_two(hour)}:${_two(minute)}';

String formatDay(DateTime date) => '${date.day} ${_months[date.month - 1]}';

String formatDate(DateTime date) =>
    '${formatDay(date)}, ${formatTime(date.hour, date.minute)}';

String formatDuration(Duration duration) {
  final days = duration.inDays;
  final hours = duration.inHours % 24;
  final minutes = duration.inMinutes % 60;
  return [
    if (days > 0) '$days d',
    if (hours > 0) '$hours h',
    if (days == 0 && (minutes > 0 || hours == 0)) '$minutes min',
  ].join(' ');
}
