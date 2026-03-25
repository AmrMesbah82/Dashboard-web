// Date: 29/9/2024
// By: Youssef Ashraf, Nada Mohammed, Mohammed Ashraf
// Last update: 29/9/2024
// Objectives: This file is responsible for providing a date time helper class that is used to format date time in the app.

// ignore_for_file: prefer_conditional_assignment

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

abstract class DateTimeHelper {
//// Helper function to format a time of day to a DateTime object
  static DateTime formatTimeOfDayToDateTime(
      TimeOfDay timeOfDay, DateTime? date) {
    if (date == null) {
      date = DateTime.now();
    }
    return DateTime(
        date.year, date.month, date.day, timeOfDay.hour, timeOfDay.minute);
  }

  /// Helper function to format a DateTime object to a string Date based on the current locale
  static String formatDate(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy', Get.locale.toString()).format(dateTime);
  }

  /// Helper function to format a DateTime object to a string Time based on the current locale

  static String formatTime(DateTime dateTime) {
    return DateFormat('h:mm a', Get.locale.toString()).format(dateTime);
  }

  /// Helper function to format a DateTime object to a string of both date and Time based on the current locale

  static String formatDateWithTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${'At'.tr} ${formatTime(dateTime)}';
  }

  // helper function to extract the hour from the time string and convert it to 24-hour format
  static String extractHour(String time) {
    List<String> parts = time.split(' ');
    List<String> timeParts = parts[0].split(':');

    int hour = int.parse(timeParts[0].trim());
    String period = parts[1].trim().toUpperCase();

    if (period == "PM" && hour != 12) {
      hour += 12;
    } else if (period == "AM" && hour == 12) {
      hour = 0;
    }

    return hour.toString();
  }

  /// Helper function to format a Duration object to a passed period format string  (2 Days, 1 Month, etc.)
  static String formatDuration(Duration duration) {
    final months = duration.inDays ~/ 30;
    if (months >= 1) {
      return '${formatInt(months)} ${months > 1 ? 'Months'.tr : 'Month'.tr}';
    } else if (duration.inDays > 0) {
      return '${formatInt(duration.inDays)} ${duration.inDays > 1 ? 'Days'.tr : 'Day'.tr}';
    } else if (duration.inHours > 0) {
      return '${formatInt(duration.inHours)} ${duration.inHours > 1 ? 'Hours'.tr : 'Hour'.tr}';
    } else if (duration.inMinutes > 0) {
      return '${formatInt(duration.inMinutes)} ${duration.inMinutes > 1 ? 'Minutes'.tr : 'Minute'.tr}';
    } else if (duration.inSeconds > 0) {
      return '${formatInt(duration.inSeconds)} ${duration.inSeconds > 1 ? 'Seconds'.tr : 'Second'.tr}';
    } else {
      return formatInt(0);
    }
  }

  /// Helper function to format a single number digit to a string based on the current locale
  static String formatInt(int number) {
    return NumberFormat('0', Get.locale.toString()).format(number);
  }

  /// Helper function to format a double number to a string based on the current locale (2.25 Format)

  static String formatDouble(double number) {
    return NumberFormat('0.00', Get.locale.toString()).format(number);
  }

  static String formatMoneyDouble(double number) {
    return NumberFormat('#,####.00', Get.locale.toString()).format(number);
  }
}
