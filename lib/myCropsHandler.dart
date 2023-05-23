import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:sugam_krishi/resources/auth_methods.dart';
import 'package:sugam_krishi/screens/Login_Signup/signupHandler.dart';

class MyCropsHandler {
  static var allLoaded = false;
  static String farmerImage = "assets/farmer_female.png";
  static List<String> allCrops = [
    "apple",
    "avocado",
    "banana",
    "beans",
    "cabbage",
    "carrot",
    "chilli-capsicum",
    "coconut",
    "coffee",
    "corn",
    "cotton",
    "cucumber",
    "date-palm",
    "eggplant-brinjal",
    "ginger",
    // "grams",
    "grape",
    "jute",
    "lemon",
    "mango",
    "millets",
    "onion",
    "orange",
    "papaya",
    "peach",
    "pomegranate",
    "potato",
    "rice",
    "rubber",
    "soybean",
    "sugarcane",
    "tomato",
    "watermelon",
    "wheat",
    "others",
  ];
  static List<String> allAnimals = [
    "cow",
    "goat",
    "horse",
    "pig",
    "poultry",
    "sheep"
  ];

  static List<cropItem> myCrops = [];
  static List<String> myAnimals = [];

  static List<cropItem> cropItemsList = [];
  static Map<String, cropItem> cropsMap = Map();

  static List<PaletteColor> colors = [];

  static Future<void> collectPalette() async {
    colors = [];
    cropItemsList = [];
    for (String imageName in allCrops) {
      final PaletteGenerator generator =
          await PaletteGenerator.fromImageProvider(
        AssetImage("assets/crops/$imageName.png"),
        size: Size(200, 100),
      );
      PaletteColor thisColor =
          generator.lightVibrantColor ?? PaletteColor(Colors.teal.shade100, 2);
      cropItem thisCropItem = cropItem(
        name: imageName,
        bgColor: thisColor.color,
      );
      colors.add(thisColor);
      cropItemsList.add(thisCropItem);
      cropsMap[imageName] = thisCropItem;
    }
    allLoaded = true;
  }

  static Future<void> fetchMyCrops(String uid) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userSnapshot.exists) {
        final userData = userSnapshot.data();
        if (userData != null && userData.containsKey('crops')) {
          final cropsData = userData['crops'];
          if (cropsData is List) {
            myCrops = cropsData
                .map((cropName) =>
                    cropsMap[cropName] ??
                    cropItem(name: cropName, bgColor: Colors.grey))
                .toList();
          }
        }
      }
    } catch (e) {
      print("Error fetching my crops: $e");
    }
  }
}

class cropItem {
  final String name;
  final Color bgColor;

  cropItem({required this.name, required this.bgColor});
}

class cropItemWidget extends StatefulWidget {
  final bool isMini;
  final cropItem item;
  cropItemWidget({Key? key, required this.item, required this.isMini})
      : super(key: key);

  @override
  State<cropItemWidget> createState() => _cropItemWidgetState();
}

class _cropItemWidgetState extends State<cropItemWidget> {
  bool currentSelected = false;

  @override
  void initState() {
    currentSelected = MyCropsHandler.myCrops.contains(widget.item);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String name = widget.item.name;
    Color bgColor = widget.item.bgColor.withOpacity(0.5);
    return widget.isMini
        ? GestureDetector(
            onTap: () {
              setState(() {
                currentSelected = !currentSelected;
                currentSelected
                    ? MyCropsHandler.myCrops.add(widget.item)
                    : MyCropsHandler.myCrops.remove(widget.item);
              });
            },
            child: Container(
              margin: EdgeInsets.all(2),
              height: 55,
              width: 55,
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: widget.item.bgColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(100),
                border: currentSelected
                    ? Border.all(
                        color: Colors.white,
                        width: 2,
                      )
                    : Border.all(style: BorderStyle.none),
              ),
              child: (name == "+")
                  ? Icon(
                      Icons.mode_edit_outline_rounded,
                      color: Colors.white,
                    )
                  : Image.asset(
                      "assets/crops/$name.png",
                      scale: 4,
                    ),
            ),
          )
        : GestureDetector(
            onTap: () {
              setState(() {
                currentSelected = !currentSelected;
                currentSelected
                    ? SignupHandler.crops.add(widget.item.name)
                    : SignupHandler.crops.remove(widget.item.name);
                currentSelected
                    ? MyCropsHandler.myCrops.add(widget.item)
                    : MyCropsHandler.myCrops.remove(widget.item);
              });
            },
            child: Container(
              margin: EdgeInsets.all(5),
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: bgColor,
                border: currentSelected
                    ? Border.all(
                        color: Colors.white,
                        width: 5,
                      )
                    : Border.all(style: BorderStyle.none),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(
                        "assets/crops/$name.png",
                        scale: (name == "millets") ? 9 : 6,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        name[0].toUpperCase() + name.substring(1),
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
