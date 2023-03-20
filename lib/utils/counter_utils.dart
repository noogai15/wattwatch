import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

int? formatCounter(String counter) {
  //Remove all 0s at the start and takes away any spaces, commas, and periods
  final firstLine = counter.trim().split('\n')[0];
  final result =
      firstLine.replaceAll(RegExp(r'[,. ]'), '').replaceAll(RegExp(r'^0+'), '');
  try {
    if (result.isEmpty || !isValidCounter(int.parse(result))) return null;
    return int.parse(result);
  } catch (e) {
    return null;
  }
}

bool isValidCounter(int counter) {
  if (counter <= 0 || counter > 1000000) return false;
  return true;
}

void saveCounterReading(int formattedCounter) async {
  final prefs = await SharedPreferences.getInstance();
  final allCounterReadings = prefs.getStringList('allCounterReadings') ?? [];
  final reading = CounterReading(formattedCounter, DateTime.now());
  final jsonString = json.encode(reading.toJson());
  allCounterReadings.add(jsonString);
  await prefs.setStringList('allCounterReadings', allCounterReadings);
}

Future<List<CounterReading>?> getAllCounterReadings() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonList = prefs.getStringList('allCounterReadings');
  final readings = <CounterReading>[];
  if (jsonList == null) return null;
  for (final jsonString in jsonList) {
    final jsonMap = json.decode(jsonString);
    final reading = CounterReading.fromJson(jsonMap);
    readings.add(reading);
  }
  return readings;
}

String formatDate(DateTime date) {
  final formattedDate = DateFormat('dd/MM/yy').format(date);
  return formattedDate;
}

class CounterReading {
  int counterState;
  DateTime date;

  CounterReading(this.counterState, this.date);

  Map<String, dynamic> toJson() => {
        'counterState': counterState,
        'date': date.toIso8601String(),
      };

  static CounterReading fromJson(json) => CounterReading(
        json['counterState'] as int,
        DateTime.parse(json['date'] as String),
      );
}
