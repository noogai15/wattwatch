import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> postCounterNum(String counterState) async {
  final prefs = await SharedPreferences.getInstance();
  final name = prefs.getString('name');
  final counterNum = prefs.getString('counterNum');
  final address = prefs.getString('address');
  final postalCode = prefs.getString('postalCode');

  final response = await http.post(
    Uri.parse('https://api.stromanbieter/zahlerstand/submit'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'name': name!,
      'counterNum': counterNum!,
      'address': address!,
      'postalCode': postalCode!,
      'counterState': counterState,
    }),
  );

  if (response.statusCode == 200) {
    // Request successful
  } else {
    // Request failed
  }
}
