import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sugam_krishi/AllDataFetchHandler.dart';
import 'package:sugam_krishi/providers/user_provider.dart';
import 'package:sugam_krishi/resources/auth_methods.dart';
import 'package:sugam_krishi/screens/Community/FeedPage.dart';
import 'package:sugam_krishi/screens/Login_Signup/signupHandler.dart';
import 'package:sugam_krishi/screens/Marketplace/MarketplacePage.dart';
import 'package:sugam_krishi/screens/Profile/ProfilePage.dart';
import 'package:sugam_krishi/screens/Utilities/UtilitiesPage.dart';
import 'package:sugam_krishi/constants.dart';

import '../myCropsHandler.dart';
import '../weather/locationSystem.dart';
import '../weather/weatherSystem.dart';

class SharedPrefsHandler {
  //The following functions save and retrieve String data from shared preferences according to the given tag
  static void saveData({required String tag, required String data}) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(tag, data);
  }

  static Future<dynamic> readData({required String tag}) async {
    final prefs = await SharedPreferences.getInstance();
    dynamic val = prefs.getString(tag);
    return val;
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final controller = ScrollController();
  void refreshPage() {
    setState(() {});
  }

  int _selectedDrawerIndex = 0;
  int currentIndex = 0;
  List<MenuModel> bottomMenuItems = <MenuModel>[];

  List listItems = [
    FeedPage(),
    MarketplacePage(),
    UtilitiesPage(),
    ProfilePage(),
  ];

  _selectedTab(int pos) {
    setState(() {
      _onSelectItem(pos);
    });

    switch (pos) {
      case 0:
        return FeedPage();
      case 1:
        return MarketplacePage();
      case 2:
        return UtilitiesPage();
      case 3:
        return ProfilePage();
      default:
        return Text("Invalid screen requested");
    }
  }

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
  }

  bool userAdded = false;
  bool weatherLoaded = false;
  bool locationLoaded = false;
  bool allDataLoaded = false;
  bool cropsLoaded = false;
  List<String> interestCrops = [];
  @override
  void initState() {
    super.initState();
    addData().then((value) {
      setState(() {
        userAdded = true;
      });
    });

    LocationSystem.getPosition().then((value) {
      setState(() {
        locationLoaded = true;
      });
    });
    WeatherSystem.fetchWeatherData(
            LocationSystem.convertPositionToString(LocationSystem.currPos))
        .then((value) {
      setState(() {
        weatherLoaded = true;
      });
    });
    AllDataFetchHandler.fetchAllData().then((value) {
      setState(() {
        allDataLoaded = true;
      });
    });
    // MyCropsHandler.collectPalette().then((value){
    //   setState(() {
    //     cropsLoaded = true;
    //   });
    // });

    fetchAllCrops().then((value) {
      setState(() {
        SignupHandler.crops = value;
        cropsLoaded = true;
      });
    });
  }

  Future<List<String>> fetchAllCrops() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> cropsSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(AuthMethods().getCurrentUserUid())
              .get();

      List<String> cropsList = [];

      if (cropsSnapshot.exists) {
        final userData = cropsSnapshot.data();
        if (userData != null && userData.containsKey('crops')) {
          final cropsData = userData['crops'];
          if (cropsData is List) {
            cropsList.addAll(cropsData.map((crop) => crop.toString()));
          }
        }
      }

      return cropsList;
    } catch (e) {
      print("Error fetching all crops: $e");
      return [];
    }
  }

  Future<void> addData() async {
    UserProvider _userProvider =
        Provider.of<UserProvider>(context, listen: false);
    await _userProvider.refreshUser();
  }

  @override
  Widget build(BuildContext context) {
    bool allLoaded = userAdded &&
        weatherLoaded &&
        locationLoaded &&
        allDataLoaded &&
        cropsLoaded;
    print(userAdded);
    print(weatherLoaded);
    print(locationLoaded);
    print(allDataLoaded);
    print(cropsLoaded);
    return allLoaded
        ? Scaffold(
            backgroundColor: Colors.white,
            body: listItems[currentIndex],
            bottomNavigationBar: BottomNavyBar(
              selectedIndex: currentIndex,
              onItemSelected: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              items: <BottomNavyBarItem>[
                BottomNavyBarItem(
                  icon: Icon(
                    Icons.home,
                    size: 24,
                  ),
                  title: Text('Community'),
                  activeColor: Colors.teal,
                ),
                BottomNavyBarItem(
                  icon: Icon(
                    FontAwesomeIcons.store,
                    size: 20,
                  ),
                  title: Text('Marketplace'),
                  activeColor: Colors.teal,
                ),
                BottomNavyBarItem(
                  icon: Icon(Icons.agriculture, size: 24),
                  title: Text('Utilities'),
                  activeColor: Colors.teal,
                ),
                BottomNavyBarItem(
                  icon: Icon(Icons.person, size: 24),
                  title: Text('Profile'),
                  activeColor: Colors.teal,
                ),
              ],
            ),
          )
        : Scaffold(
            body: Center(
              child: LoadingAnimationWidget.prograssiveDots(
                size: 60,
                color: Colors.tealAccent.shade700,
              ),
            ),
          );
  }

  _modalBottomSheetMenu() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 440.0,
            color: Color(0xFF737373),
            child: Column(
              children: <Widget>[
                Container(
                  height: 300.0,
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  decoration: new BoxDecoration(
                      color: Colors.white, //Color(0xFF737373),
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  child: ListView.builder(
                      itemCount: bottomMenuItems.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              color: Colors.teal[100],
                            ),
                            child: Icon(
                              bottomMenuItems[index].icon,
                              color: Colors.teal,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                          ),
                          title: Text(
                            bottomMenuItems[index].title,
                            style: TextStyle(color: Colors.teal, fontSize: 18),
                          ),
                          subtitle: Text(bottomMenuItems[index].subtitle),
                          onTap: () {
                            Navigator.pop(context);
                            debugPrint(bottomMenuItems[index].title);
                          },
                        );
                      }),
                ),

                //SizedBox(height: 10),

                Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    margin: EdgeInsets.symmetric(vertical: 30),
                    child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.close,
                            size: 25, color: Colors.grey[900]))),
              ],
            ),
          );
        });
  }
}

class MenuModel {
  String title;
  String subtitle;
  IconData icon;

  MenuModel(this.title, this.subtitle, this.icon);
}
