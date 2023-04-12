import 'package:shared_preferences/shared_preferences.dart';

Future<String?> getName() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('name');
}

void setName(String name) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('name', name);
}

bool isValidName(String name) {
  if (name.isEmpty) return false;
  final nameRegex = RegExp(r'^[a-zA-Z]+([ -][a-zA-Z]+)+$');
  return nameRegex.hasMatch(name);
}
