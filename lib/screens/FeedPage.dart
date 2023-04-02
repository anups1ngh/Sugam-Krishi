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
import '../constants.dart';

class FeedPage extends StatefulWidget {
  String location;
  String weatherIcon;
  int temperature;
  String currentDate;
  List dailyWeatherForecast;
  String currentWeatherStatus;
  FeedPage({super.key, required this.location, required this.weatherIcon, required this.currentDate, required this.dailyWeatherForecast, required this.currentWeatherStatus, required this.temperature});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  Constants _constants = Constants();
  String day_night = TimeOfDay.now().hour < 17 ? "day" : "night";

  void refreshVariables(){
      LocationSystem.getPosition();
      WeatherSystem.fetchWeatherData(LocationSystem.convertPositionToString(LocationSystem.currPos));
      setState(() {
        widget.location = WeatherSystem.location;
        widget.currentWeatherStatus = WeatherSystem.currentWeatherStatus;
        widget.dailyWeatherForecast = WeatherSystem.dailyWeatherForecast;
        widget.currentDate = WeatherSystem.currentDate;
        widget.temperature = WeatherSystem.temperature;
        widget.weatherIcon = WeatherSystem.weatherIcon;
      });
  }
  void initState() {
    day_night = TimeOfDay.now().hour < 17 ? "day" : "night";
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
            refreshVariables();
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
                                widget.currentDate,
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
                                  widget.location,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                  ),
                                ),
                                IconButton(
                                  onPressed: (){
                                    refreshVariables();
                                    // widget.notifyParent();
                                  },
                                  icon: const Icon(
                                    Icons.refresh_rounded,
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
                                        dailyForecastWeather: widget.dailyWeatherForecast,
                                      )),
                            );
                          },
                          child: Row(
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
                                            widget.temperature.toString(),
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
                                  ],
                                ),
                              ),
                              //WEATHER ICON
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child:
                                SizedBox(
                                  height: 100,
                                  child: Image.asset(
                                    "assets/$day_night/" + widget.weatherIcon,
                                    scale: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        //WEATHER SUMMARY
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20),
                          child: Text(
                            widget.currentWeatherStatus,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
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
