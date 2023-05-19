import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../keys.dart';

class WeatherSystem{
  static String searchWeatherAPI = "https://api.weatherapi.com/v1/forecast.json?key=$weather_API_KEY&days=7&q=";

  // static String location = '';
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
  static Future<void> fetchWeatherData(String searchText) async {
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
      // location = getShortLocationName(locationData["name"]);

      var parsedDate = DateTime.parse(locationData["localtime"].substring(0, 10));
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
        return "${wordList[0]}\n${wordList[1]}";
      } else {
        return wordList[0];
      }
    } else {
      return " ";
    }
  }
}