import 'dart:convert';
import 'dart:ui';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:animated_switcher_plus/animated_switcher_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:sugam_krishi/providers/user_provider.dart';
import 'package:sugam_krishi/providers/value_providers.dart';
import 'package:sugam_krishi/screens/Utilities/Diagnosis/cameraScreen.dart';
import 'package:sugam_krishi/screens/Community/postPage.dart';
import 'package:sugam_krishi/screens/Community/post_item.dart';
import 'package:sugam_krishi/weather/detail_page.dart';
import 'package:http/http.dart' as http;
import '../../models/post.dart';
import '../../weather/locationSystem.dart';
import '../../weather/weatherSystem.dart';
import '../../weather/weather_item.dart';
import '../../constants.dart';
import 'package:sugam_krishi/models/user.dart' as model;

class FeedPage extends StatefulWidget {
  FeedPage(
      {super.key,});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  Constants _constants = Constants();
  String day_night = TimeOfDay.now().hour < 17 ? "day" : "night";
  late ScrollController scrollController;
  TextEditingController dropDownController = TextEditingController();
  String postsFilter = "All Posts";
  bool showFAB = true;
  bool showWeatherCard = true;
  bool isUserNull = false;

  String location = LocationSystem.locationText;
  String weatherIcon = WeatherSystem.weatherIcon;
  int temperature = WeatherSystem.temperature;
  String currentDate = WeatherSystem.currentDate;
  List dailyWeatherForecast = WeatherSystem.dailyWeatherForecast;
  String currentWeatherStatus = WeatherSystem.currentWeatherStatus;

  void refreshVariables() {
    LocationSystem.getPosition();
    WeatherSystem.fetchWeatherData(
        LocationSystem.convertPositionToString(LocationSystem.currPos));
    setState(() {
      location = LocationSystem.locationText;
      currentWeatherStatus = WeatherSystem.currentWeatherStatus;
      dailyWeatherForecast = WeatherSystem.dailyWeatherForecast;
      currentDate = WeatherSystem.currentDate;
      temperature = WeatherSystem.temperature;
      weatherIcon = WeatherSystem.weatherIcon;
    });
  }

  String greeting() {
    int hour = TimeOfDay.now().hour;
    String time;
    if (hour >= 4 && hour < 12)
      time = "Morning";
    else if (hour >= 12 && hour < 17)
      time = "Afternoon";
    else if (hour >= 17 && hour < 20)
      time = "Evening";
    else
      time = "Night";

    return "Good " + time + " ";
  }

  _scrollListener() {
    // print(scrollController.offset);
    // if (scrollController.offset >= scrollController.position.maxScrollExtent &&
    //     !scrollController.position.outOfRange) {
    //   // setState(() {
    //   //   print(scrollController.position.pixels);
    //   // });
    // }
    // if (scrollController.offset <= scrollController.position.minScrollExtent &&
    //     !scrollController.position.outOfRange) {
    //   // setState(() {
    //   //   print(scrollController.position.pixels);
    //   // });
    // }
    if (scrollController.offset >= 265) {
      // Provider.of<ValueProviders>(context, listen: false).setShowWeatherCard(false);
    }
    // scrollController.animateTo(offset, duration: duration, curve: curve);
  }

  void initState() {
    day_night = TimeOfDay.now().hour < 17 ? "day" : "night";
    scrollController = ScrollController();
    dropDownController = TextEditingController();
    scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    dropDownController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    model.User user = Provider.of<UserProvider>(context).getUser;
    showFAB = Provider.of<ValueProviders>(context).shouldShowFAB;
    print("Show FAB : " + showFAB.toString());
    showWeatherCard =
        Provider.of<ValueProviders>(context).shouldShowWeatherCard;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xffE0F2F1),
      appBar: AppBar(
        actions: [
          Visibility(
            visible: !showWeatherCard,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailPage(
                      dailyForecastWeather: dailyWeatherForecast,
                      location: location,
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.teal.shade200,
                ),
                height: 24,
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          //TEMPERATURE
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    temperature.toString(),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'o',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //WEATHER ICON
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: SizedBox(
                        height: 40,
                        child: Image.asset(
                          "assets/$day_night/" + weatherIcon,
                          scale: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 1,
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
          child: NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              // print(notification.metrics.extentInside);
              // if(notification.direction == ScrollDirection.forward){
              //   Provider.of<ValueProviders>(context, listen: false).setShowFAB(true);
              //   if(notification.metrics.pixels >= 265)
              //     Provider.of<ValueProviders>(context, listen: false).setShowWeatherCard(false);
              // } else if(notification.direction == ScrollDirection.reverse){
              //   Provider.of<ValueProviders>(context, listen: false).setShowFAB(false);
              //   if(notification.metrics.pixels <= 265)
              //     Provider.of<ValueProviders>(context, listen: false).setShowWeatherCard(true);
              // }
              return true;
            },
            child: SingleChildScrollView(
              controller: scrollController,
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //HELLO MESSAGE
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        // child: Text(
                        //   greeting() + "\n " + user.username,
                        //   style: GoogleFonts.poppins(
                        //     fontSize: 24,
                        //     fontWeight: FontWeight.w500,
                        //     color: Colors.black87,
                        //     height: 1.1,
                        //   ),
                        // ),
                        child: RichText(
                          text: TextSpan(
                            text: greeting(),
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                              color: Colors.black87,
                              height: 1.15,
                            ),
                            children: [
                              TextSpan(
                                text: "\n" + user.username,
                                style: GoogleFonts.poppins(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                  height: 1.15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // WEATHER CARD
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 10),
                      height: size.height * .22,
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
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //DATE AND LOCATION
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                child: Text(
                                  currentDate,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: size.width * 0.04,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    location,
                                    overflow: TextOverflow.fade,
                                    style: TextStyle(
                                      color: Colors.white,
                                      //fontSize: 16.0,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      refreshVariables();
                                      // widget.notifyParent();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2),
                                      child: const Icon(
                                        Icons.refresh_rounded,
                                        color: Colors.white,
                                      ),
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
                                    dailyForecastWeather:
                                        dailyWeatherForecast,
                                    location: location,
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      //TEMPERATURE
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 0),
                                            child: Text(
                                              temperature.toString(),
                                              style: TextStyle(
                                                // fontSize: 80,
                                                fontWeight: FontWeight.bold,
                                                fontSize: size.width * 0.2,
                                                foreground: Paint()
                                                  ..shader = _constants.shader,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            'o',
                                            style: TextStyle(
                                              //fontSize: 40,
                                              fontSize: size.width * 0.08,
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
                                  child: SizedBox(
                                    //height: 100,
                                    height: size.height * 0.08,
                                    child: Image.asset(
                                      "assets/$day_night/" + weatherIcon,
                                      scale: 0.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          //WEATHER SUMMARY
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              currentWeatherStatus,
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

                    // POST FILTER
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 5, right: 5, top: 15, bottom: 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Community Posts",
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        height: 60,
                        width: 150,
                        child: CustomDropdown(
                          hintText: 'Filter',
                          items: const ["All Posts", "My Posts"],
                          controller: dropDownController,
                          excludeSelected: false,
                          onChanged: (value) {
                            setState(() {
                              postsFilter = value;
                            });
                          },
                        ),
                      ),
                    ),

                    //POSTS FEED
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .snapshots(),
                      builder: (context, snapshot){
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: SpinKitThreeBounce(
                              color: Colors.white,
                              size: 22,
                            ),
                          );
                        }
                        print(snapshot.data!.docs.length);
                        return ListView.builder(
                          padding: EdgeInsets.only(bottom: 100),
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            print(postsFilter);
                            if (postsFilter == "My Posts") {
                              if (user.uid ==
                                  snapshot.data!.docs[index].data()["uid"])
                                return PostItem(
                                  snap: snapshot.data!.docs[index].data(),
                                );
                            } else {
                              return PostItem(
                                snap: snapshot.data!.docs[index].data(),
                              );
                            }
                          },
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 400),
        offset: showFAB ? Offset.zero : Offset(0, 2),
        child: AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: showFAB ? 1 : 0,
            child: Padding(
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
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                    ),
                    context: context,
                    builder: (BuildContext context) {
                      return postPage(
                        userName: user.username,
                        userPhoto: user.photoUrl,
                      );
                    },
                  );
                },
              ),
            )),
      ),
    );
  }
}
