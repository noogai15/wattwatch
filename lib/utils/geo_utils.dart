import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;
import 'package:shared_preferences/shared_preferences.dart';

Future<Placemark> getUserLocation() async {
  loc.LocationData? myLocation;
  String error;
  final location = loc.Location();
  try {
    myLocation = await location.getLocation();
  } on PlatformException catch (e) {
    if (e.code == 'PERMISSION_DENIED') {
      error = 'please grant permission';
      print(error);
    }
    if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
      error = 'permission denied- please enable it from app settings';
      print(error);
    }
    myLocation = null;
  }
  final currentLocation = myLocation!;
  final placemarks = await placemarkFromCoordinates(
      currentLocation.latitude!, currentLocation.longitude!);
  return placemarks[0];
}

Future<String> getPostalCode() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('postalCode')!;
}

Future<String> getStreet() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('street')!;
}

void savePostalCode(Placemark location) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('postalCode', location.postalCode!);
}

void saveStreet(Placemark location) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('street', location.street!);
}

void saveGeoPrefs() async {
  final location = await getUserLocation();
  saveStreet(location);
  savePostalCode(location);
}
