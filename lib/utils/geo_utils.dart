import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;

Future<Placemark> getUserLocation() async {
  //call this async method from whereever you need

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
  final location = await getUserLocation();
  return location.postalCode!;
}

Future<String> getStreet() async {
  final location = await getUserLocation();
  return location.street!;
}
