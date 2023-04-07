import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sugam_krishi/models/user.dart' as model;
import 'package:sugam_krishi/providers/user_provider.dart';
import 'package:sugam_krishi/resources/auth_methods.dart';
import 'package:sugam_krishi/screens/editProfilePage.dart';
import 'package:sugam_krishi/utils/utils.dart';

import '../constants.dart';

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

  Future<void> getLocationText() async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        LocationSystem.currPos.latitude, LocationSystem.currPos.longitude);

    setState(() {
      location = placemarks[0].subLocality.toString() +
          ", " +
          placemarks[0].locality.toString();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    model.User user = Provider.of<UserProvider>(context).getUser;
    LocationSystem.getPosition();
    getLocationText();
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
                height: 30,
              ),
              // Container(
              //   height: 120,
              //   width: 120,
              //   decoration: BoxDecoration(
              //     border: Border.all(
              //       color: Colors.teal.shade400,
              //       width: 0.4,
              //     ),
              //     borderRadius: BorderRadius.circular(100),
              //   ),
              //   child: Padding(
              //     padding: const EdgeInsets.all(0),
              //     child: ClipRRect(
              //       borderRadius: BorderRadius.circular(100),
              //         child: Image.network(
              //           user.photoUrl,
              //         ),
              //     ),
              //   ),
              // ),
              CircleAvatar(
                backgroundColor: Colors.green.shade100,
                backgroundImage: NetworkImage(
                  user.photoUrl,
                ),
                radius: 64,
              ),
              SizedBox(
                height: 10,
              ),
              //USER-NAME
              Text(
                user.username,
                style: GoogleFonts.poppins(
                  fontSize: 22,
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
              SizedBox(
                height: 10,
              ),
              //EDIT BUTTON
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
                height: 50,
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
