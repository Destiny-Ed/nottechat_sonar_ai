import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  formatDateAndTime() {
    return DateFormat('MMM d, yyyy – h:mm a').format(this);
  }

  formatTime() {
    return DateFormat('h:mm a').format(this);
  }
}

extension StringExtension on String {
  //to capitalize first letter of the string/sentence.
  String get capitalize => (isNotEmpty) ? "${this[0].toUpperCase()}${substring(1)}" : "";

  //to capitalize every first letter of each word in string/sentence.
  String get cap => split(" ").map((str) => (str.isNotEmpty) ? str.capitalize : "").join(" ");
}
