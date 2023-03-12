import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> postCounterNum(int counterState) async {
  final prefs = await SharedPreferences.getInstance();
  final name = prefs.getString('name');
  final counterNum = prefs.getString('counterNum');
  final address = prefs.getString('address');
  final postalCode = prefs.getString('postalCode');

  final url = Uri.https('https://api.stromanbieter', 'zahlerstand/submit');
  final response = await http.post(url, body: {
    'name': name,
    'counterNum': counterNum,
    'address': address,
    'postalCode': postalCode,
    'counterState': counterState,
    'date': DateTime.now(),
  });
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    // Request successful
  } else {
    // Request failed
  }
}
