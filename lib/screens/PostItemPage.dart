import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sugam_krishi/constants.dart';
import 'package:sugam_krishi/providers/user_provider.dart';
import 'package:sugam_krishi/resources/firestore_methods.dart';
import 'package:sugam_krishi/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:toggle_switch/toggle_switch.dart';

enum SELLTYPE { SELL, RENT }

class postItemPage extends StatefulWidget {
  final String userPhoto;
  final String userName;
  const postItemPage(
      {Key? key, required this.userPhoto, required this.userName})
      : super(key: key);

  @override
  State<postItemPage> createState() => _postItemPageState();
}

class _postItemPageState extends State<postItemPage> {
  SELLTYPE selltype = SELLTYPE.SELL;
  int _toggleStateIndex = 0;
  bool isLoading = false;

  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemPriceController = TextEditingController();
  final TextEditingController _itemQuantityController = TextEditingController();
  final TextEditingController _itemDescriptionController =
  TextEditingController();
  Uint8List? _image;
  bool _photoSelected = false;
  String category = "";
  String res = "";
  String location = "";
  String itemName = "";
  String stateName = "";
  List<dynamic> data = [];
  String modal_price = "";

  selectImage(ImageSource _source) async {
    Uint8List im = await pickImage(_source);
    // set state because we need to display the image we selected on the circle avatar
    setState(() {
      _image = im;
      _photoSelected = true;
    });
  }

  Future<void> getLocationText() async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        LocationSystem.currPos.latitude, LocationSystem.currPos.longitude);

    setState(() {
      location = placemarks[0].subLocality.toString() +
          ", " +
          placemarks[0].locality.toString();
      stateName = placemarks[0].administrativeArea.toString();
    });
  }

  void showToastText(String text) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  String formatName(String name){
    return name.replaceAll("_", " ").split(" ").map((word){
      if(word.isEmpty) return word;
      else return word[0].toUpperCase() + word.substring(1);
    }).toList().join(" ");
  }
  String capitalizeFirst(String name){
    return name[0].toUpperCase() + name.substring(1);
  }
  Future<void> fetchData(String itemName) async {
    final response = await http.get(Uri.parse(
      "https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070"
          "?api-key=579b464db66ec23bdd000001cdd3946e44ce4aad7209ff7b23ac571b"
          "&format=json"
          "&filters%5Bstate%5D=${location.replaceAll(" ", "%20")}"
          "&filters%5Bcommodity%5D=${capitalizeFirst(itemName)}",
    ));
    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      setState(() {
        data = decodedData['records'];
        for (final record in data) {
          final modalPrice = record['modal_price'];
          print("Modal price = $modalPrice");
          modal_price = modalPrice;
        }
      });
    } else {
      print('Failed to fetch data');
    }
  }

  void postItem(
      String uid,
      String username,
      String category,
      String profImage,
      String contact,
      ) async {
    setState(() {
      isLoading = true;
    });
    try {
      if (_itemDescriptionController.text.isEmpty && _image != null) {
        res = await FireStoreMethods().uploadMarketplaceItem(
            "",
            uid,
            username,
            category,
            _image,
            profImage,
            _itemPriceController.text,
            location,
            contact,
            _itemNameController.text,
            _itemQuantityController.text);
      } else if (_image == null && _itemDescriptionController.text.isNotEmpty) {
        res = await FireStoreMethods().uploadMarketplaceItem(
            _itemDescriptionController.text,
            uid,
            username,
            category,
            null,
            profImage,
            _itemPriceController.text,
            location,
            contact,
            _itemNameController.text,
            _itemQuantityController.text);
      } else if (_image == null && _itemDescriptionController.text.isEmpty) {
        res = await FireStoreMethods().uploadMarketplaceItem(
            "",
            uid,
            username,
            category,
            null,
            profImage,
            _itemPriceController.text,
            location,
            contact,
            _itemNameController.text,
            _itemQuantityController.text);
      } else {
        res = await FireStoreMethods().uploadMarketplaceItem(
            _itemDescriptionController.text,
            uid,
            username,
            category,
            _image,
            profImage,
            _itemPriceController.text,
            location,
            contact,
            _itemNameController.text,
            _itemQuantityController.text);
      }
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        showToastText(
          'Posted!',
        );
        clearImage();
        _itemNameController.clear();
        _itemPriceController.clear();
        _itemDescriptionController.clear();
        Navigator.pop(context);
      } else {
        setState(() {
          isLoading = false;
        });
        showToastText(
          res,
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showToastText(
        e.toString(),
      );
    }
  }

  void clearImage() {
    setState(() {
      _image = null;
    });
  }

  @override
  initState() {
    selltype = SELLTYPE.SELL;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    LocationSystem.getPosition();
    getLocationText();
    return SafeArea(
        child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xffE0F2F1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 7),
                              child: CircleAvatar(
                                radius: 24,
                                backgroundColor: Color(0xff64FFDA).withOpacity(0.1),
                                backgroundImage: NetworkImage(
                                  widget.userPhoto,
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 0),
                                  child: Text(
                                    widget.userName,
                                    style: GoogleFonts.poppins(
                                        fontSize: 18, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        FilledButton(
                          style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all(Colors.greenAccent.shade700),
                          ),
                          onPressed: () {
                            postItem(
                                userProvider.getUser.uid,
                                userProvider.getUser.username,
                                selltype == SELLTYPE.SELL ? "Sell" : "Rent",
                                userProvider.getUser.photoUrl,
                                userProvider.getUser.contact);
                          },
                          child: isLoading
                              ? Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                              : Text(
                            "Post",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),

                    // Here, default theme colors are used for activeBgColor, activeFgColor, inactiveBgColor and inactiveFgColor
                    ToggleSwitch(
                      initialLabelIndex: _toggleStateIndex,
                      totalSwitches: 2,
                      labels: ['Sell', 'Rent'],
                      activeBgColor: [Colors.greenAccent.shade700],
                      activeFgColor: Colors.white,
                      inactiveBgColor: Colors.black26,
                      inactiveFgColor: Colors.black45,
                      onToggle: (index) {
                        setState(() {
                          index == 0
                              ? selltype = SELLTYPE.SELL
                              : selltype = SELLTYPE.RENT;
                          _toggleStateIndex = index!;
                          category = _toggleStateIndex == 0 ? "Sell" : "Rent";
                        });
                      },
                    ),

                    selltype == SELLTYPE.SELL ? sell() : rent(),
                    _photoSelected
                        ? Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: MemoryImage(
                            _image!,
                          ),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(
                          width: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      height: MediaQuery.of(context).size.height * 0.3,
                      // height: 300,
                      width: MediaQuery.of(context).size.width * 1,
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          // Expanded(
                          //   child: Image.memory(
                          //     _image!,
                          //     fit: BoxFit.cover,
                          //   ),
                          // ),
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              icon: Icon(
                                Icons.cancel_outlined,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                setState(() {
                                  _photoSelected = false;
                                });
                              },
                            ),
                          )
                        ],
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FilledButton(
                          child: Row(
                            children: const [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 10),
                                child: FaIcon(FontAwesomeIcons.image),
                              ),
                              Text("Add a Photo"),
                            ],
                          ),
                          onPressed: () {
                            selectImage(ImageSource.gallery);
                          },
                        ),
                        FilledButton(
                          child: Row(
                            children: const [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 10),
                                child: FaIcon(FontAwesomeIcons.cameraRetro),
                              ),
                              Text("Take a Photo"),
                            ],
                          ),
                          onPressed: () {
                            selectImage(ImageSource.camera);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )));
  }

  Widget sell() {
    return SingleChildScrollView(
      padding:
      EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 15.0,
        ),
        child: Column(

          // mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6,),
                child: TextField(
                  controller: _itemNameController,
                  onChanged: (value) {
                    itemName = value;
                    fetchData(itemName);
                  },
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      gapPadding: 0,
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white70,
                        width: 1.2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      gapPadding: 0,
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.green,
                        width: 1,
                      ),
                    ),
                    hintText: "What are you selling?",
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: TextField(
                  maxLines: 5,
                  controller: _itemDescriptionController,
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white70,
                        width: 1.2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.green,
                        width: 1,
                      ),
                    ),
                    hintText: "Write something about your " + _itemNameController.text + " yield",
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6,),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.465,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: _itemPriceController,
                        autofocus: false,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.white70,
                              width: 1.2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.green,
                              width: 1,
                            ),
                          ),
                          hintText: "Enter price of item in Rs./kg",
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.465,
                      child: TextField(
                        controller: _itemQuantityController,
                        autofocus: false,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.white70,
                              width: 1.2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.green,
                              width: 1,
                            ),
                          ),
                          hintText:
                          'Enter quantity of ${_itemNameController.text} up for sell',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_circle_rounded,
                      color: Colors.tealAccent.shade700,
                    ),
                    Text(
                      'The mandi price for ${itemName} is ₹${modal_price} ',
                      overflow: TextOverflow.fade,
                    )
                  ],
                ),
              ),
            ]),
      ),
    );
  }

  Widget rent() {
    return SingleChildScrollView(
      padding:
      EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 15.0,
        ),
        child: Column(

          // mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: TextField(
                  controller: _itemNameController,
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white70,
                        width: 1.2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.green,
                        width: 1,
                      ),
                    ),
                    hintText: "What are you renting?",
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: TextField(
                  maxLines: 5,
                  controller: _itemDescriptionController,
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white70,
                        width: 1.2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.green,
                        width: 1,
                      ),
                    ),
                    hintText: "Write something about your " + _itemNameController.text,
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 15),
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: _itemPriceController,
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white70,
                        width: 1.2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.green,
                        width: 1,
                      ),
                    ),
                    hintText: "Enter rent price of item in Rs./hour",
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ]),
      ),
    );
  }
}

// item name
// item description
// item price