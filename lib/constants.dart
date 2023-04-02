import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class UserLocation{
  final String latitude;
  final String longitude;
  UserLocation({required this.latitude, required this.longitude});
}

class LocationSystem{
  static Position currPos = Position(
    latitude: 20.3514487,
    longitude: 85.8213786,
    timestamp: DateTime.now(),
    accuracy: 75,
    altitude: 0,
    heading: 0,
    speed: 0,
    speedAccuracy: 0,
  );
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
    Position? _pos = await Geolocator.getLastKnownPosition(forceAndroidLocationManager: true);
    if(_pos != null )
      currPos = _pos;
    else
      determinePosition();

    print(currPos);
  }
  static String convertPositionToString(Position pos){
    return pos.latitude.toString() + "," + pos.longitude.toString();
  }
}
class WeatherSystem{
  static String API_KEY = "6341f24a80484da9a1b43817232903";
  static String searchWeatherAPI = "https://api.weatherapi.com/v1/forecast.json?key=" + API_KEY + "&days=7&q=";

  static String location = 'Bhubaneswar';
  static String weatherIcon = '116.png';
  static int temperature = 0;
  static int windSpeed = 0;
  static int humidity = 0;
  static int cloud = 0;
  static String currentDate = '';
  static List hourlyWeatherForecast = [];
  static List dailyWeatherForecast = [];
  static String currentWeatherStatus = '';
  static String day_night = TimeOfDay.now().hour < 17 ? "day" : "night";

  //searchText = latitude,longitude
  static void fetchWeatherData(String searchText) async {
    try {
      var searchResult =
      await http.get(Uri.parse(searchWeatherAPI + searchText));
      final weatherData = Map<String, dynamic>.from(
          json.decode(searchResult.body) ?? 'No data');
      // print(weatherData);
      var locationData = weatherData["location"];
      // print(locationData);
      var currentWeather = weatherData["current"];
      // print(currentWeather);
      location = getShortLocationName(locationData["name"]);

      var parsedDate =
      DateTime.parse(locationData["localtime"].substring(0, 10));
      var newDate = DateFormat('MMMMEEEEd').format(parsedDate);
      currentDate = newDate;

      //updateWeather
      currentWeatherStatus = currentWeather["condition"]["text"];
      day_night = TimeOfDay.now().hour < 17 ? "day" : "night";
      weatherIcon = currentWeather["condition"]["icon"].toString();
      weatherIcon = weatherIcon.substring(weatherIcon.length - 7);
      // print(weatherIcon);
      temperature = currentWeather["temp_c"].toInt();
      windSpeed = currentWeather["wind_kph"].toInt();
      humidity = currentWeather["humidity"].toInt();
      cloud = currentWeather["cloud"].toInt();
      print(currentWeather["temp_c"].toInt());
      //Forecast data
      dailyWeatherForecast = weatherData["forecast"]["forecastday"];
      hourlyWeatherForecast = dailyWeatherForecast[0]["hour"];
      // print(dailyWeatherForecast);
    } catch (e) {
      //debugPrint(e);
    }
  }
  static String getShortLocationName(String s) {
    List<String> wordList = s.split(" ");

    if (wordList.isNotEmpty) {
      if (wordList.length > 1) {
        return wordList[0] + " " + wordList[1];
      } else {
        return wordList[0];
      }
    } else {
      return " ";
    }
  }
}

class Constants {
  final primaryColor = const Color(0xff00796B);
  final secondaryColor = const Color(0xff80CBC4);
  final tertiaryColor = const Color(0xff205cf1);
  final blackColor = const Color(0xff1a1d26);

  final greyColor = const Color(0xffd9dadb);

  final Shader shader = const LinearGradient(
    colors: <Color>[Color(0xffffffff), Color(0xffB2DFDB)],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));
  final Shader secondaryShader = const LinearGradient(
    colors: <Color>[Color(0xff26A69A), Color(0xff009688)],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  final linearGradientTeal = const LinearGradient(
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
      colors: [Color(0xff80CBC4), Color(0xff00796B)],
      stops: [0.0, 1.0]);
  final linearGradientGreen = LinearGradient(
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
      colors: [Color(0xffB9F6CA), Color(0xff00E676)],
      stops: [0.0, 1.0]);
}