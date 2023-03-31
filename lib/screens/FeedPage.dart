import 'dart:convert';
import 'dart:ui';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sugam_krishi/screens/cameraScreen.dart';
import 'package:sugam_krishi/screens/postPage.dart';
import 'package:sugam_krishi/weather/ui/detail_page.dart';
import 'package:http/http.dart' as http;
import '../weather/components/weather_item.dart';
import '../weather/constants.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final TextEditingController _cityController = TextEditingController();
  final Constants _constants = Constants();
  static String API_KEY = "6341f24a80484da9a1b43817232903";

  String day_night =
      TimeOfDay.now().hour < 17 ? "day" : "night";

  String location = 'Bhubaneswar';
  String weatherIcon = '116.png';
  int temperature = 0;
  int windSpeed = 0;
  int humidity = 0;
  int cloud = 0;
  String currentDate = '';

  List hourlyWeatherForecast = [];
  List dailyWeatherForecast = [];

  String currentWeatherStatus = '';

  //API Call
  String searchWeatherAPI = "https://api.weatherapi.com/v1/forecast.json?key=" +
      API_KEY +
      "&days=7&q=";
  void fetchWeatherData(String searchText) async {
    try {
      var searchResult =
          await http.get(Uri.parse(searchWeatherAPI + searchText));

      final weatherData = Map<String, dynamic>.from(
          json.decode(searchResult.body) ?? 'No data');

      var locationData = weatherData["location"];

      var currentWeather = weatherData["current"];

      setState(() {
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
        print(weatherIcon);
        temperature = currentWeather["temp_c"].toInt();
        windSpeed = currentWeather["wind_kph"].toInt();
        humidity = currentWeather["humidity"].toInt();
        cloud = currentWeather["cloud"].toInt();

        //Forecast data
        dailyWeatherForecast = weatherData["forecast"]["forecastday"];
        hourlyWeatherForecast = dailyWeatherForecast[0]["hour"];
        print(dailyWeatherForecast);
      });
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

  void initState() {
    fetchWeatherData(location);
    // day.period;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xffE0F2F1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        // leading: const BackButton(
        //   color: Colors.black,
        // ),
        automaticallyImplyLeading: false,
        title: Text(
            "KrishiCommunity",
          textAlign: TextAlign.left,
          style: GoogleFonts.openSans(
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          edgeOffset: 40,
          strokeWidth: 2.5,
          color: Color(0xff0ba99b),
          onRefresh: () async {
            await Future.delayed(Duration(milliseconds: 800));
            setState(() {

            });
          },
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    height: size.height * .24,
                    decoration: BoxDecoration(
                      gradient: _constants.linearGradientTeal,
                      boxShadow: [
                        BoxShadow(
                          color: _constants.primaryColor.withOpacity(.2),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        //DATE AND LOCATION
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                currentDate,
                                style: const TextStyle(
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/pin.png",
                                  width: 20,
                                ),
                                const SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  location,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    _cityController.clear();
                                    showMaterialModalBottomSheet(
                                        context: context,
                                        builder: (context) => SingleChildScrollView(
                                              controller:
                                                  ModalScrollController.of(context),
                                              child: Container(
                                                height: size.height * .5,
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                  vertical: 30,
                                                ),
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                      width: 70,
                                                      child: Divider(
                                                        thickness: 3.5,
                                                        color:
                                                            _constants.primaryColor,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    TextField(
                                                      onChanged: (searchText) {
                                                        fetchWeatherData(
                                                            searchText);
                                                      },
                                                      controller: _cityController,
                                                      autofocus: true,
                                                      decoration: InputDecoration(
                                                          prefixIcon: Icon(
                                                            Icons.search,
                                                            color: _constants
                                                                .primaryColor,
                                                          ),
                                                          suffixIcon:
                                                              GestureDetector(
                                                            onTap: () =>
                                                                _cityController
                                                                    .clear(),
                                                            child: Icon(
                                                              Icons.close,
                                                              color: _constants
                                                                  .primaryColor,
                                                            ),
                                                          ),
                                                          hintText:
                                                              'Search city e.g. Bhubaneswar',
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color: _constants
                                                                  .primaryColor,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(10),
                                                          )),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ));
                                  },
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        //WEATHER INFO AND ICON
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DetailPage(
                                        dailyForecastWeather: dailyWeatherForecast,
                                      )),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    //TEMPERATURE
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 0),
                                          child: Text(
                                            temperature.toString(),
                                            style: TextStyle(
                                              fontSize: 80,
                                              fontWeight: FontWeight.bold,
                                              foreground: Paint()
                                                ..shader = _constants.shader,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'o',
                                          style: TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            foreground: Paint()
                                              ..shader = _constants.shader,
                                          ),
                                        ),
                                      ],
                                    ),
                                    //WEATHER SUMMARY
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Expanded(
                                        child: Text(
                                          currentWeatherStatus,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Flexible(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: //WEATHER ICON
                                  SizedBox(
                                    height: 100,
                                    child: Image.asset(
                                      "assets/$day_night/" + weatherIcon,
                                      scale: 0.6,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        //DIVIDER
                        // Container(
                        //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                        //   child: const Divider(
                        //     // thickness: 1,
                        //     color: Colors.white70,
                        //   ),
                        // ),
                        //EXTRAS
                        // Container(
                        //   padding: const EdgeInsets.symmetric(horizontal: 40),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //     children: [
                        //       WeatherItem(
                        //         value: windSpeed.toInt(),
                        //         unit: 'km/h',
                        //         imageUrl: 'assets/windspeed.png',
                        //       ),
                        //       WeatherItem(
                        //         value: humidity.toInt(),
                        //         unit: '%',
                        //         imageUrl: 'assets/humidity.png',
                        //       ),
                        //       WeatherItem(
                        //         value: cloud.toInt(),
                        //         unit: '%',
                        //         imageUrl: 'assets/cloud.png',
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: FloatingActionButton.extended(
          elevation: 1,
          // backgroundColor: Color(0xff00897B),
          backgroundColor: Colors.greenAccent.shade700,
          icon: FaIcon(
            FontAwesomeIcons.penToSquare,
            size: 20,
            color: Colors.white,
          ),
          label: Text(
            "Share to the Community",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          onPressed: () {
            showModalBottomSheet<void>(
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
              context: context,
              builder: (BuildContext context) {
                return postPage();
              },
            );
          },
        ),
      ),
    );
  }
}
