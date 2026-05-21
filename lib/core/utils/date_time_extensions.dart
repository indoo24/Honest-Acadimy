import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  DateTime get dateOnly => DateTime(year, month, day);

  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  String get shortDay => DateFormat('EEE').format(this);

  String get dayNumber => DateFormat('d').format(this);

  String get monthName => DateFormat('MMM').format(this);

  String get timeLabel => DateFormat('h:mm a').format(this);

  String get readableDate => DateFormat('EEE, MMM d').format(this);
}
