// Objectives: This file is responsible for providing a date time helper class that is used to format date time in the app.

// ignore_for_file: prefer_conditional_assignment

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

abstract class FormDateTimeHelper {
  static DateTime formatTimeOfDayToDateTime(
      TimeOfDay timeOfDay, DateTime? date) {
    if (date == null) {
      date = DateTime.now();
    }
    return DateTime(
        date.year, date.month, date.day, timeOfDay.hour, timeOfDay.minute);
  }

  static String formatTimeOfDayToString(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hourOfPeriod == 0 ? 12 : timeOfDay.hourOfPeriod;
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('dd MMM, yyyy', Get.locale.toString()).format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('h:mm a', Get.locale.toString()).format(dateTime);
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

  static String extractMinutes(String time) {
    List<String> parts = time.split(' ');
    List<String> timeParts = parts[0].split(':');

    String minutes = timeParts[1].trim();
    return minutes;
  }

  static String getMonthName(int month, {bool arabic = false}) {
    final months = arabic
        ? [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ]
        : [
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
      'Dec'
    ];
    return months[month - 1];
  }

  static String formatDuration(Duration duration) {
    final months = duration.inDays ~/ 30;
    if (months >= 1) {
      return '${formatInt(months)} ${months > 1 ? 'Months'.tr : 'Month'.tr}';
    } else if (duration.inDays > 0) {
      return '${formatInt(duration.inDays)} ${duration.inDays > 1 ? 'Days'.tr : 'Day'.tr}';
    } else if (duration.inHours > 0) {
      return '${formatInt(duration.inHours)} ${duration.inHours > 1 ? 'Hours'.tr : 'Hour'.tr}';
    } else if (duration.inMinutes > 0) {
      return '${formatInt(duration.inMinutes)} ${duration.inMinutes > 1 ? 'timeMinutes'.tr : 'Minute'.tr}';
    } else if (duration.inSeconds > 0) {
      return '${formatInt(duration.inSeconds)} ${duration.inSeconds > 1 ? 'Seconds'.tr : 'Second'.tr}';
    } else {
      return formatInt(0);
    }
  }

  static String formatInt(int number) {
    return NumberFormat('0', Get.locale.toString()).format(number);
  }

  static String formatDouble(double number) {
    return NumberFormat('0.00', Get.locale.toString()).format(number);
  }

  static Map<String, String> monthsMap = {
    'Jan': 'يناير',
    'Feb': 'فبراير',
    'Mar': 'مارس',
    'Apr': 'أبريل',
    'May': 'مايو',
    'Jun': 'يونيو',
    'Jul': 'يوليو',
    'Aug': 'أغسطس',
    'Sep': 'سبتمبر',
    'Oct': 'أكتوبر',
    'Nov': 'نوفمبر',
    'Dec': 'ديسمبر',
  };
  static String? getMonthNameFromDateTime(DateTime dateTime) {
    // Map month number to its corresponding name
    Map<int, String> monthNames = {
      1: 'Jan',
      2: 'Feb',
      3: 'Mar',
      4: 'Apr',
      5: 'May',
      6: 'Jun',
      7: 'Jul',
      8: 'Aug',
      9: 'Sep',
      10: 'Oct',
      11: 'Nov',
      12: 'Dec',
    };
    return monthNames[dateTime.month];
  }

  static List<String> sortMonthsFromCurrentMonth() {
    // List of months
    List<String> months = [
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

    // Get current month
    DateTime now = DateTime.now();
    int currentMonthIndex =
        now.month - 1; // months are 1-indexed, so subtract 1

    // Sort months from current month to the end of the year
    List<String> sortedMonths = months.sublist(currentMonthIndex)
      ..addAll(months.sublist(0, currentMonthIndex));

    return sortedMonths;
  }

  static String getMediaTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat('MMMM_dd_yyyy').format(dateTime);
    return formattedDate;
  }
}
