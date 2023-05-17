import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../keys.dart';

class UserLocation{
  final String latitude;
  final String longitude;
  UserLocation({required this.latitude, required this.longitude});
}
class LocationSystem{
  static Position currPos = Position(
    latitude: 20.175937,
    longitude: 85.706187,
    timestamp: DateTime.now(),
    accuracy: 75,
    altitude: 0,
    heading: 0,
    speed: 0,
    speedAccuracy: 0,
  );
  static List<Placemark> placemarks = [];
  static String locationText = "";
  static Future<void> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // if (!serviceEnabled) {
    //   // Location services are not enabled don't continue
    //   // accessing the position and request users of the
    //   // App to enable the location services.
    //   // return Future.error('Location services are disabled.');
    //
    //
    // }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        // return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    currPos = await Geolocator.getCurrentPosition();
    // print(currPos);
  }
  static Future<void> getPosition() async{
    determinePosition();
    getLocationText();
  }
  static String convertPositionToString(Position pos){
    return "${pos.latitude},${pos.longitude}";
  }
  static Future<void> getLocationText() async {
    placemarks = await placemarkFromCoordinates(currPos.latitude, currPos.longitude);
    print(placemarks[0]);
    locationText = "${placemarks[0].subLocality},\n${placemarks[0].locality}";
  }
}