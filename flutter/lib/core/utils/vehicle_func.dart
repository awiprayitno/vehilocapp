import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Color getVehicleColor(int speed, int gpsdt) {
  DateTime now = DateTime.now();
  DateTime gpsDateTime =
      DateTime.fromMillisecondsSinceEpoch(gpsdt * 1000, isUtc: true);
  Duration difference = now.difference(gpsDateTime);

  if (speed == 0 && difference.inDays > 7) {
    return Colors.grey;
  } else if (speed == 0) {
    return Colors.red;
  } else {
    return Colors.green;
  }
}

Color getSensorColor(String? status) {
  if (status == 'ON') {
    return Colors.green;
  } else {
    return Colors.red;
  }
}

String formatDateTime(DateTime dateTime) {
  final now = DateTime.now();

  if (dateTime.year == now.year &&
      dateTime.month == now.month &&
      dateTime.day == now.day) {
    return DateFormat.Hm().format(dateTime);
  } else if (dateTime.year == now.year) {
    return DateFormat('dd-MMM').format(dateTime);
  } else {
    return DateFormat.y().format(dateTime);
  }
}
