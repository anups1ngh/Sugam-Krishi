import 'dart:convert';

import 'package:awesome_select/awesome_select.dart';
import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sugam_krishi/constants.dart';
import 'package:sugam_krishi/myCropsHandler.dart';
import 'package:sugam_krishi/providers/user_provider.dart';
import 'package:sugam_krishi/resources/firestore_methods.dart';
import 'package:sugam_krishi/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:toggle_switch/toggle_switch.dart';

import '../../weather/locationSystem.dart';

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
  final TextEditingController _itemDescriptionController = TextEditingController();
  Uint8List? _image;
  bool _photoSelected = false;
  String category = "";
  String res = "";
  String locationAdministrativeArea = "";
  String itemName = "";
  String itemUnit = "";
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
    modal_price = "";
    final response = await http.get(Uri.parse(
      "https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070"
          "?api-key=579b464db66ec23bdd000001cdd3946e44ce4aad7209ff7b23ac571b"
          "&format=json"
          "&filters%5Bstate%5D=${locationAdministrativeArea.replaceAll(" ", "%20")}"
          "&filters%5Bcommodity%5D=${capitalizeFirst(itemName)}",
    ));
    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
        data = decodedData['records'];
        for (final record in data) {
          final modalPrice = record['modal_price'];
          print("Modal price = $modalPrice");
          modal_price = modalPrice;
        }
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
      if(_itemNameController.text.isEmpty && itemName.isEmpty){
        res = "Item name cannot be empty";
      }else {
        res = await FireStoreMethods().uploadMarketplaceItem(
          uid: uid,
          username: username,
          profImage: profImage,
          location: LocationSystem.locationText,
          contact: contact,

          category: category,
          file: _image,
          itemName: _itemNameController.text.isNotEmpty ? capitalizeFirst(_itemNameController.text) : capitalizeFirst(itemName),
          description: _itemDescriptionController.text,
          quantity: _itemQuantityController.text,
          price: _itemPriceController.text,
        );
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
    LocationSystem.getLocationText();
    locationAdministrativeArea = LocationSystem.placemarks[0].administrativeArea.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return SafeArea(
        child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                    Divider(
                      height: 5,
                      thickness: 1,
                      indent: 15,
                      endIndent: 15,
                    ),

                    // Here, default theme colors are used for activeBgColor, activeFgColor, inactiveBgColor and inactiveFgColor
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ToggleSwitch(
                        customTextStyles: [GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white)],
                        initialLabelIndex: _toggleStateIndex,
                        totalSwitches: 2,
                        labels: ['Sell', 'Rent'],
                        radiusStyle: true,
                        activeBgColor: (selltype == SELLTYPE.SELL) ? [Colors.greenAccent.shade700] : [Color.fromARGB(255, 239, 198, 90)],
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

  String sellUnit = "Kg";
  Widget sell() {
    List<CoolDropdownItem<String>> listOfCrops = [];
    List<CoolDropdownItem<String>> listOfUnits = [
      CoolDropdownItem<String>(
        label: "Kg",
        value: "Kg",
      ),
      CoolDropdownItem<String>(
        label: "Quintal",
        value: "Quintal",
      ),
    ];
    final DropdownController dropdownController = DropdownController(duration: Duration(milliseconds: 200));
    final DropdownController sellUnitsDropdownController = DropdownController(duration: Duration(milliseconds: 200));
    void fillData(){
      for(cropItem crop in MyCropsHandler.myCrops){
        String cropName = crop.name[0].toUpperCase()+crop.name.substring(1).toLowerCase();
        listOfCrops.add(
          CoolDropdownItem<String>(
            label: cropName,
            value: crop.name,
            icon: Container(
              padding: EdgeInsets.all(5),
              height: 50,
              width: 50,
              child: Image.asset("assets/crops/${crop.name}.png",),
            ),
          ),
        );
      }
    }
    fillData();
    bool isMandiLoading = false;
    InlineSpan getInlineTextSpan(){
      if(isMandiLoading){
        return TextSpan(
          text: "Loading mandi pricing for $itemName",
          style: GoogleFonts.openSans(fontSize: 14, color: Colors.black),
        );
      }
      if(itemName.isEmpty){
        return TextSpan(
          text: "Select item to view its mandi pricing",
          style: GoogleFonts.openSans(fontSize: 14, color: Colors.black),
        );
      }
      if(modal_price.isEmpty) {
        return TextSpan(
          text: "Sorry, cannot find mandi pricing for ",
          style: GoogleFonts.openSans(fontSize: 14, color: Colors.black),
          children: [
            TextSpan(
              text: itemName[0].toUpperCase()+itemName.substring(1),
              style: GoogleFonts.openSans(fontSize: 14, color: MyCropsHandler.cropsMap[itemName]?.bgColor),
            ),
          ],
        );
      } else{
        return TextSpan(
          text: "Mandi pricing for ",
          style: GoogleFonts.openSans(fontSize: 14, color: Colors.black),
          children: [
            TextSpan(
              text: itemName[0].toUpperCase()+itemName.substring(1),
              style: GoogleFonts.openSans(fontSize: 14, color: MyCropsHandler.cropsMap[itemName]?.bgColor),
            ),
            TextSpan(
              text: " is ",
            ),
            TextSpan(
              text: "Rs. $modal_price",
              style: GoogleFonts.openSans(fontSize: 14, color: Colors.tealAccent.shade700),
            ),
            TextSpan(
              text: " per quintal",
            ),
          ],
        );
      }
    }
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //ITEM NAME
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //ICON AND TEXT
                  Text(
                    "Crop",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 20
                    ),
                  ),
                  CoolDropdown<String>(
                    controller: dropdownController,
                    dropdownList: listOfCrops,
                    defaultItem: null,
                    onChange: (a) {
                      itemName = a[0].toLowerCase()+a.substring(1);
                      setState(() {
                        isMandiLoading = true;
                      });
                      fetchData(itemName).then((value){setState(() {
                        isMandiLoading = false;
                      });});
                      print(itemName);
                      print(modal_price);
                      dropdownController.close();
                    },
                    resultOptions: ResultOptions(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      mainAxisAlignment: MainAxisAlignment.end,
                      placeholder: "Select Crop",
                      width: 250,
                      render: ResultRender.all,
                      icon: SizedBox(
                        width: 10,
                        height: 10,
                        child: CustomPaint(
                          painter: DropdownArrowPainter(color: Colors.green),
                        ),
                      ),
                    ),
                    dropdownOptions: DropdownOptions(
                      left: 50,
                      width: 160,
                    ),
                    dropdownItemOptions: DropdownItemOptions(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      selectedBoxDecoration: BoxDecoration(
                        color: Color(0XFFEFFAF0),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //DESCRIPTION
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "Description",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: 20
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: TextFormField(
                textInputAction: TextInputAction.next,
                maxLines: 3,
                controller: _itemDescriptionController,
                autofocus: false,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),


            //PRICE AND QUANTITY

            //QUANTITY
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "Quantity",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: 20
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 18),
                      textInputAction: TextInputAction.next,
                      controller: _itemQuantityController,
                      autofocus: false,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      //unit
                    ),
                  ),
                  CoolDropdown<String>(
                    controller: sellUnitsDropdownController,
                    dropdownList: listOfUnits,
                    defaultItem: null,
                    onChange: (a) {
                      setState(() {
                        itemUnit = a;
                        sellUnit = a;
                        print(sellUnit);
                      });
                      sellUnitsDropdownController.close();
                    },
                    resultOptions: ResultOptions(
                      textStyle: TextStyle(color: Colors.greenAccent.shade700, fontSize: 16, fontWeight: FontWeight.w400),
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      mainAxisAlignment: MainAxisAlignment.end,
                      placeholder: "Kg",
                      width: 120,
                      render: ResultRender.label,
                      icon: SizedBox(
                        width: 10,
                        height: 10,
                        child: CustomPaint(
                          painter: DropdownArrowPainter(color: Colors.green),
                        ),
                      ),
                    ),
                    dropdownOptions: DropdownOptions(
                    ),
                    dropdownItemOptions: DropdownItemOptions(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      selectedBoxDecoration: BoxDecoration(
                        color: Color(0XFFEFFAF0),
                      ),
                    ),
                  ),
                ],
              ),
            ),


            //PRICE
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "Price",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: 20
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text("Rs. ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Colors.greenAccent.shade700),),
                  ),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 18),
                      textInputAction: TextInputAction.next,
                      controller: _itemPriceController,
                      autofocus: false,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      //unit
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text(" per $sellUnit ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.greenAccent.shade700),),
                  ),
                ],
              ),
            ),

            //MANDI PRICE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.lightbulb_circle_rounded,
                      color: Colors.tealAccent.shade700,
                      size: 35,
                    ),
                  ),
                  Expanded(
                    child: RichText(
                      text: getInlineTextSpan(),
                    ),
                  )
                ],
              ),
            ),
          ]),
    );
  }

  Widget rent() {
    List<CoolDropdownItem<String>> listOfRentUnits = [
      CoolDropdownItem<String>(
        label: "per hour",
        value: "per hour",
      ),
      CoolDropdownItem<String>(
        label: "per day",
        value: "per day",
      ),
    ];
    final DropdownController rentUnitsDropdownController = DropdownController(duration: Duration(milliseconds: 200));
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //ITEM NAME
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //ICON AND TEXT
                  Text(
                    "Item",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 20
                    ),
                  ),
                  Container(
                    width: 250,
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      maxLines: 1,
                      controller: _itemNameController,
                      autofocus: false,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //DESCRIPTION
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "Description",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: 20
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: TextFormField(
                textInputAction: TextInputAction.next,
                maxLines: 3,
                controller: _itemDescriptionController,
                autofocus: false,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),


            //PRICE
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "Price",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: 20
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text("Rs. ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Colors.greenAccent.shade700),),
                  ),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 18),
                      textInputAction: TextInputAction.next,
                      controller: _itemPriceController,
                      autofocus: false,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      //unit
                    ),
                  ),
                  CoolDropdown<String>(
                    controller: rentUnitsDropdownController,
                    dropdownList: listOfRentUnits,
                    defaultItem: null,
                    onChange: (a) {
                      itemUnit = a;
                      rentUnitsDropdownController.close();
                    },
                    resultOptions: ResultOptions(
                      textStyle: TextStyle(color: Colors.greenAccent.shade700, fontSize: 16, fontWeight: FontWeight.w400),
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      mainAxisAlignment: MainAxisAlignment.end,
                      placeholder: "per hour",
                      width: 120,
                      render: ResultRender.label,
                      icon: SizedBox(
                        width: 10,
                        height: 10,
                        child: CustomPaint(
                          painter: DropdownArrowPainter(color: Colors.green),
                        ),
                      ),
                    ),
                    dropdownOptions: DropdownOptions(
                    ),
                    dropdownItemOptions: DropdownItemOptions(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      selectedBoxDecoration: BoxDecoration(
                        color: Color(0XFFEFFAF0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30,),
          ],
      ),
    );
  }
}

// item name
// item description
// item price