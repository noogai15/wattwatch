import 'dart:convert';

import 'package:http/http.dart' as http;

Future<void> postCounterNum(
    String counterId, int counterNum, DateTime date) async {
  final response = await http.post(
    Uri.parse('https://api.stromanbieter/zahlerstand/submit'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'param1': 'value1',
      'param2': 'value2',
    }),
  );

  if (response.statusCode == 200) {
    // Request successful
  } else {
    // Request failed
  }
}
