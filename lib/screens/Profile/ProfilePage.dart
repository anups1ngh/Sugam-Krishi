import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sugam_krishi/models/user.dart' as model;
import 'package:sugam_krishi/myCropsHandler.dart';
import 'package:sugam_krishi/providers/user_provider.dart';
import 'package:sugam_krishi/resources/auth_methods.dart';
import 'package:sugam_krishi/screens/Login_Signup/selectCropsPage.dart';
import 'package:sugam_krishi/screens/Profile/editProfilePage.dart';
import 'package:sugam_krishi/utils/utils.dart';

import '../../constants.dart';
import '../../weather/locationSystem.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthMethods _authMethods = AuthMethods();
  bool _isLoading = false;
  Uint8List? _image;
  String location = "";

  selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    // set state because we need to display the image we selected on the circle avatar
    setState(() {
      _image = im;
    });
  }

  void refresh() {
    setState(() {});
  }

  @override
  void initState() {
    LocationSystem.getPosition();
    location = LocationSystem.locationText.replaceAll("\n", " ");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    model.User user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      backgroundColor: Color(0xffE0F2F1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Text(
          "Profile",
          textAlign: TextAlign.left,
          style: GoogleFonts.openSans(
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              CircleAvatar(
                backgroundColor: Colors.green.shade100,
                backgroundImage: NetworkImage(
                  user.photoUrl,
                ),
                radius: 64,
              ),
              //USER-NAME
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  user.username,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                  ),
                ),
              ),
              //DESCRIPTION
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  // user.description,
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed velit risus, dapibus pretium rhoncus pharetra, faucibus non dolor.",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w200,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 10,
              ),

              //CROPS SELECTED
              SizedBox(
                height: 60,
                child: ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  scrollDirection: Axis.horizontal,
                  itemCount: MyCropsHandler.myCrops.length,
                  itemBuilder: (context, index){
                    if(index == MyCropsHandler.myCrops.length){
                      return GestureDetector(
                        onTap: (){
                          // Navigator.of(context).push(MaterialPageRoute(
                          //     builder: ((context) => SelectCropsPage())
                          // ),
                          // );
                        },
                        child: Align(
                          widthFactor: 0.5,
                          alignment: Alignment.centerLeft,
                          child: cropItemWidget(
                            item: cropItem(name: "+", bgColor: Colors.grey),
                            isMini: true,
                          ),
                        ),
                      );
                    }
                    return Align(
                      widthFactor: 0.5,
                      alignment: Alignment.centerLeft,
                      child: cropItemWidget(
                          item: MyCropsHandler.myCrops[index],
                          isMini: true,
                      ),
                    );
                  },
                ),
              ),

              //EMAIL-ID
              // Text(
              //   user.email,
              //   style: GoogleFonts.poppins(
              //     fontSize: 12,
              //     fontWeight: FontWeight.w300,
              //   ),
              // ),

              //EDIT BUTTON
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 150,
                height: 42,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.amberAccent,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(
                          photoURL: user.photoUrl,
                          username: user.username,
                          contact: formatContact(user.contact),
                          location: location,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    "Edit Profile",
                    style: GoogleFonts.openSans(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),

              //MENU
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.teal.shade400, width: 0.4),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.teal.shade100,
                    ),
                    child: Icon(
                      Icons.phone_android_rounded,
                    ),
                  ),
                  title: Text(
                    formatContact(user.contact),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.teal.shade400, width: 0.4),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.teal.shade100,
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                    ),
                  ),
                  title: Text(
                    location,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: GestureDetector(
                  onTap: () async {
                    await _authMethods.signOut();
                  },
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.teal.shade400, width: 0.4),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.teal.shade100,
                      ),
                      child: Icon(
                        Icons.logout_rounded,
                      ),
                    ),
                    title: Text(
                      "Sign Out",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.redAccent,
                      ),
                    ),
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