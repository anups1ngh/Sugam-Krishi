import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sugam_krishi/myCropsHandler.dart';
import 'package:sugam_krishi/screens/HomePage.dart';
import 'package:sugam_krishi/screens/Login_Signup/signupHandler.dart';

import '../../resources/auth_methods.dart';
import '../../utils/utils.dart';

class SelectCropsPage extends StatefulWidget {
  const SelectCropsPage({Key? key}) : super(key: key);

  @override
  State<SelectCropsPage> createState() => _SelectCropsPageState();
}

class _SelectCropsPageState extends State<SelectCropsPage> {
  bool isLoading = false;
  bool goodToGo = false;

  Future<void> signUP() async {
    setState(() {
      isLoading = true;
    });

    String res = await AuthMethods().signUpUser(
      email: SignupHandler.email,
      password: SignupHandler.password,
      username: SignupHandler.username,
      contact: SignupHandler.contact,
      file: SignupHandler.image,
      // crops: SignupHandler.crops,
    );
    handleResult(res);
  }

  void handleResult(String res) {
    if (res == "success") {
      setState(() {
        goodToGo = true;
        isLoading = false;
      });
      showToastText("Account created successfully");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } else {
      setState(() {
        isLoading = false;
      });
      showToastText(res);
    }
  }

  List<ProfileItem> profileItems = [
    ProfileItem(imagePath: "assets/farmer_male.png"),
    ProfileItem(imagePath: "assets/farmer_female.png"),
  ];

  Future<Uint8List> convertImage(String localPath) async {
    final ByteData bytes = await rootBundle.load(localPath);
    Uint8List image = bytes.buffer.asUint8List();
    return image;
  }

  Uint8List? _image;
  bool photoSelected = false;
  selectImage(ImageSource source) async {
    Uint8List im = await pickImage(source);
    // set state because we need to display the image we selected on the circle avatar
    setState(() {
      _image = im;
      photoSelected = true;
      profileItems.add(
        ProfileItem(
          image: _image,
        ),
      );
      profileItems[2].setAllValues();
      profileSelectIndex = 3;
    });
  }

  int profileSelectIndex = 0;
  int cropSelectIndex = -1;
  @override
  void initState() {
    profileItems[0].setAllValues();
    profileItems[1].setAllValues();
    // SignupHandler.image = profileItems[1].image!;
    MyCropsHandler.collectPalette().then((value) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    print("photoSelected = $photoSelected");
    return Scaffold(
      backgroundColor: Color(0xffE0F2F1),
      appBar: AppBar(
        // toolbarHeight: 70,
        elevation: 1,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            "Hi, ${SignupHandler.username}",
            style: TextStyle(color: Colors.black, fontSize: 22),
            textAlign: TextAlign.left,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 10, right: 10, bottom: 4),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.tealAccent.shade700,
              ),
              onPressed: () {
                signUP();
                if (goodToGo)
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: ((context) => HomePage())));
              },
              child: isLoading
                  ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Text(
                      "Done",
                      style: GoogleFonts.openSans(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //SELECT PROFILE PHOTO
            Padding(
              padding: const EdgeInsets.only(left: 5, top: 20, bottom: 5),
              child: Text(
                "Choose profile photo",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 22,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        SignupHandler.image = profileItems[0].image!;
                        profileSelectIndex = 0;
                      });
                    },
                    child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                        width: (profileSelectIndex == 0)
                            ? width * .35
                            : width * .3,
                        height: 130,
                        decoration: new BoxDecoration(
                            color: (profileSelectIndex == 0)
                                ? Colors.tealAccent.shade700
                                : Colors.transparent,
                            border: (profileSelectIndex == 0)
                                ? Border.all(
                                    color: Colors.white70,
                                    width: 5,
                                  )
                                : Border.all(style: BorderStyle.none),
                            shape: BoxShape.circle,
                            image: new DecorationImage(
                              fit: BoxFit.scaleDown,
                              image: AssetImage("assets/farmer_male.png"),
                            ))),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        SignupHandler.image = profileItems[1].image!;
                        profileSelectIndex = 1;
                      });
                    },
                    child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                        width: (profileSelectIndex == 1)
                            ? width * .35
                            : width * .3,
                        height: 130,
                        decoration: new BoxDecoration(
                            color: (profileSelectIndex == 1)
                                ? Colors.tealAccent.shade700
                                : Colors.transparent,
                            border: (profileSelectIndex == 1)
                                ? Border.all(
                                    color: Colors.white70,
                                    width: 5,
                                  )
                                : Border.all(style: BorderStyle.none),
                            shape: BoxShape.circle,
                            image: new DecorationImage(
                              fit: BoxFit.scaleDown,
                              image: AssetImage("assets/farmer_female.png"),
                            ))),
                  ),
                  photoSelected
                      ? Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          width: (profileSelectIndex == 2)
                              ? width * .35
                              : width * .3,
                          height: 130,
                          decoration: new BoxDecoration(
                              color: (profileSelectIndex == 2)
                                  ? Colors.tealAccent.shade700
                                  : Colors.transparent,
                              border: (profileSelectIndex == 2)
                                  ? Border.all(
                                      color: Colors.white70,
                                      width: 5,
                                    )
                                  : Border.all(style: BorderStyle.none),
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                fit: BoxFit.scaleDown,
                                image: MemoryImage(_image!),
                              )),
                        )
                      : Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          width: width * .25,
                          height: 130,
                          decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                          child: Center(
                            child: IconButton(
                              icon: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 30,
                              ),
                              onPressed: () {
                                pickImage(ImageSource.gallery);
                              },
                            ),
                          ),
                        ),
                ],
              ),
            ),

            //SELECT CROPS
            Padding(
              padding: const EdgeInsets.only(left: 5, top: 20, bottom: 5),
              child: Text(
                "Select crops you grow",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500, fontSize: 22),
              ),
            ),
            GridView.builder(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              shrinkWrap: true,
              primary: false,
              physics: NeverScrollableScrollPhysics(),
              itemCount: MyCropsHandler.cropItemsList.length,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemBuilder: (context, index) {
                return cropItemWidget(
                    item: MyCropsHandler.cropItemsList[index], isMini: false);
              },
            ),

            //DONE BUTTON
            Align(
              alignment: Alignment.center,
              child: Container(
                margin: EdgeInsets.only(bottom: 30, top: 10),
                width: width * .7,
                height: 50,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.tealAccent.shade700,
                  ),
                  onPressed: () {
                    signUP();
                    if (goodToGo)
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: ((context) => HomePage())));
                  },
                  child: isLoading
                      ? CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          "Done",
                          style: GoogleFonts.openSans(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileItem {
  final String? imagePath;
  Uint8List? image;

  ProfileItem({this.imagePath, this.image});

  Future<void> setAllValues() async {
    if (image == null) {
      final ByteData bytes = await rootBundle.load(imagePath!);
      image = bytes.buffer.asUint8List();
    }
  }
}
