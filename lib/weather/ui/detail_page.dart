import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../components/weather_item.dart';
import '../../constants.dart';

class DetailPage extends StatefulWidget {
  final dailyForecastWeather;
  final String location;

  const DetailPage({Key? key, this.dailyForecastWeather, required this.location}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final Constants _constants = Constants();
  String day_night = TimeOfDay.now().hour < 17 ? "day" : "night";
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var weatherData = widget.dailyForecastWeather;

    //function to get weather
    Map getForecastWeather(int index) {
      int maxWindSpeed = weatherData[index]["day"]["maxwind_kph"].toInt();
      int avgHumidity = weatherData[index]["day"]["avghumidity"].toInt();
      int chanceOfRain =
          weatherData[index]["day"]["daily_chance_of_rain"].toInt();

      var parsedDate = DateTime.parse(weatherData[index]["date"]);
      var forecastDate = DateFormat('EEEE, d MMMM').format(parsedDate);

      String weatherName = weatherData[index]["day"]["condition"]["text"];
      print(weatherData);
      day_night = TimeOfDay.now().hour < 17 ? "day" : "night";
      String weatherIcon = weatherData[index]["day"]["condition"]["icon"];
      weatherIcon = weatherIcon.substring(weatherIcon.length - 7);
      print(weatherIcon);
      int minTemperature = weatherData[index]["day"]["mintemp_c"].toInt();
      int maxTemperature = weatherData[index]["day"]["maxtemp_c"].toInt();

      var forecastData = {
        'maxWindSpeed': maxWindSpeed,
        'avgHumidity': avgHumidity,
        'chanceOfRain': chanceOfRain,
        'forecastDate': forecastDate,
        'weatherName': weatherName,
        'weatherIcon': weatherIcon,
        'minTemperature': minTemperature,
        'maxTemperature': maxTemperature
      };
      return forecastData;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leadingWidth: 45,
        title: Text('Forecasts for ${widget.location}', style: GoogleFonts.openSans(fontSize: 18), overflow: TextOverflow.fade,),
        centerTitle: true,
        backgroundColor: _constants.primaryColor,
        elevation: 1,
      ),
      body: ListView.builder(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: 5),
              itemCount: 7,
              itemBuilder: (context, index) {
                if(index == 0)
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding:
                          const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          height: size.height * .30,
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
                              //WEATHER INFO AND ICON
                              Row(
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
                                              padding: const EdgeInsets.only(top: 10),
                                              child: Text(
                                                getForecastWeather(0)["minTemperature"].toString(),
                                                style: TextStyle(
                                                  fontSize: 40,
                                                  fontWeight: FontWeight.w600,
                                                  // color: _constants.greyColor,
                                                  foreground: Paint()
                                                    ..shader = _constants.secondaryShader,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 10),
                                              child: Text(
                                                'o',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  // color: Color(0xff00897B),
                                                  foreground: Paint()
                                                    ..shader = _constants.secondaryShader,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 0),
                                              child: Text(
                                                getForecastWeather(0)["maxTemperature"].toString(),
                                                style: TextStyle(
                                                  fontSize: 60,
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
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        //WEATHER ICON
                                        SizedBox(
                                          height: 100,
                                          child: Image.asset(
                                            "assets/$day_night/" +
                                                getForecastWeather(0)["weatherIcon"],
                                            scale: 0.4,
                                            height: 140,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              //WEATHER SUMMARY
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10),
                                child: Text(
                                  // getForecastWeather(0)["weatherName"].toString(),
                                  "Moderate or heavy rain with thunder",
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 18.5,
                                  ),
                                ),
                              ),
                              //DIVIDER
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 2),
                                child: const Divider(
                                  // thickness: 1,
                                  color: Colors.white70,
                                ),
                              ),
                              //EXTRAS
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 40),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    WeatherItem(
                                      value: getForecastWeather(0)["maxWindSpeed"],
                                      unit: "km/h",
                                      imageUrl: "assets/windspeed.png",
                                    ),
                                    WeatherItem(
                                      value: getForecastWeather(0)["avgHumidity"],
                                      unit: "%",
                                      imageUrl: "assets/humidity.png",
                                    ),
                                    WeatherItem(
                                      value: getForecastWeather(0)["chanceOfRain"],
                                      unit: "%",
                                      imageUrl: "assets/cloud.png",
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                else
                  return Card(
                    elevation: 3.0,
                    margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                getForecastWeather(index)["forecastDate"].toString(),
                                style: const TextStyle(
                                  color: Color(0xff26A69A),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        getForecastWeather(
                                            index)["minTemperature"]
                                            .toString(),
                                        style: TextStyle(
                                          color: _constants.greyColor,
                                          fontSize: 30,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '°',
                                        style: TextStyle(
                                            color: _constants.greyColor,
                                            fontSize: 30,
                                            fontWeight: FontWeight.w600,
                                            fontFeatures: const [
                                              FontFeature.enable('sups'),
                                            ]),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        getForecastWeather(
                                            index)["maxTemperature"]
                                            .toString(),
                                        style: TextStyle(
                                          color: _constants.blackColor,
                                          fontSize: 30,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '°',
                                        style: TextStyle(
                                            color: _constants.blackColor,
                                            fontSize: 30,
                                            fontWeight: FontWeight.w600,
                                            fontFeatures: const [
                                              FontFeature.enable('sups'),
                                            ]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/$day_night/' +
                                        getForecastWeather(index)["weatherIcon"],
                                    width: 30,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    getForecastWeather(index)["weatherName"].toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    getForecastWeather(index)["chanceOfRain"]
                                        .toString() +
                                        "%",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Image.asset(
                                    'assets/cloud.png',
                                    width: 30,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
              }),
      // Stack(
      //   alignment: Alignment.center,
      //   clipBehavior: Clip.none,
      //   children: [
      //     Positioned(
      //       bottom: 0,
      //       left: 0,
      //       child: Container(
      //         height: size.height * .75,
      //         width: size.width,
      //         decoration: const BoxDecoration(
      //           color: Colors.white,
      //           borderRadius: BorderRadius.only(
      //             topLeft: Radius.circular(50),
      //             topRight: Radius.circular(50),
      //           ),
      //         ),
      //         child: Stack(
      //           clipBehavior: Clip.none,
      //           children: [
      //             Positioned(
      //               top: -50,
      //               right: 20,
      //               left: 20,
      //               child: Container(
      //                 height: 300,
      //                 width: size.width * .7,
      //                 decoration: BoxDecoration(
      //                   gradient: const LinearGradient(
      //                       begin: Alignment.topLeft,
      //                       end: Alignment.center,
      //                       colors: [
      //                         Color(0xffa9c1f5),
      //                         Color(0xff6696f5),
      //                       ]),
      //                   boxShadow: [
      //                     BoxShadow(
      //                       color: Colors.blue.withOpacity(.1),
      //                       offset: const Offset(0, 25),
      //                       blurRadius: 3,
      //                       spreadRadius: -10,
      //                     ),
      //                   ],
      //                   borderRadius: BorderRadius.circular(15),
      //                 ),
      //                 child: Stack(
      //                   clipBehavior: Clip.none,
      //                   children: [
      //                     Positioned(
      //                       child: Image.asset("assets/$day_night/" +
      //                           getForecastWeather(0)["weatherIcon"],
      //                       scale: 0.5,
      //                       height: 140,),
      //                       width: 120,
      //                     ),
      //                     Positioned(
      //                         top: 150,
      //                         left: 30,
      //                         child: Padding(
      //                           padding: const EdgeInsets.only(bottom: 10.0),
      //                           child: Text(
      //                             getForecastWeather(0)["weatherName"],
      //                             style: const TextStyle(
      //                                 color: Colors.white, fontSize: 20),
      //                           ),
      //                         )),
      //                     Positioned(
      //                       bottom: 20,
      //                       left: 20,
      //                       child: Container(
      //                         width: size.width * .8,
      //                         padding:
      //                             const EdgeInsets.symmetric(horizontal: 20),
      //                         child: Row(
      //                           mainAxisAlignment:
      //                               MainAxisAlignment.spaceBetween,
      //                           children: [
      //                             WeatherItem(
      //                               value:
      //                                   getForecastWeather(0)["maxWindSpeed"],
      //                               unit: "km/h",
      //                               imageUrl: "assets/windspeed.png",
      //                             ),
      //                             WeatherItem(
      //                               value: getForecastWeather(0)["avgHumidity"],
      //                               unit: "%",
      //                               imageUrl: "assets/humidity.png",
      //                             ),
      //                             WeatherItem(
      //                               value:
      //                                   getForecastWeather(0)["chanceOfRain"],
      //                               unit: "%",
      //                               imageUrl: "assets/cloud.png",
      //                             ),
      //                           ],
      //                         ),
      //                       ),
      //                     ),
      //                     Positioned(
      //                       top: 20,
      //                       right: 20,
      //                       child: Row(
      //                         crossAxisAlignment: CrossAxisAlignment.start,
      //                         children: [
      //                           Text(
      //                             getForecastWeather(0)["maxTemperature"]
      //                                 .toString(),
      //                             style: TextStyle(
      //                               fontSize: 80,
      //                               fontWeight: FontWeight.bold,
      //                               foreground: Paint()
      //                                 ..shader = _constants.shader,
      //                             ),
      //                           ),
      //                           Text(
      //                             'o',
      //                             style: TextStyle(
      //                               fontSize: 40,
      //                               fontWeight: FontWeight.bold,
      //                               foreground: Paint()
      //                                 ..shader = _constants.shader,
      //                             ),
      //                           ),
      //                         ],
      //                       ),
      //                     ),
      //                     Positioned(
      //                       top: 320,
      //                       left: 0,
      //                       child: SizedBox(
      //                         height: 1000,
      //                         width: size.width * .9,
      //                         child:
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }
}
