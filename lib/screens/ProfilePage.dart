import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sugam_krishi/models/user.dart' as model;
import 'package:sugam_krishi/providers/user_provider.dart';
import 'package:sugam_krishi/screens/editProfilePage.dart';
import 'package:sugam_krishi/utils/utils.dart';

import '../constants.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 25,
              ),

              // Profile Image with image picker
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(
                        user.photoUrl,
                      ),
                      radius: 64,
                    ),
                    Positioned(
                      bottom: 0,
                      left: 80,
                      child: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: IconButton(
                          onPressed: () {
                            showModalBottomSheet<void>(
                              isScrollControlled: true,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(18))),
                              context: context,
                              builder: (BuildContext context) {
                                return EditProfilePage();
                              },
                            );
                          },
                          icon: const Icon(Icons.edit, color: Colors.black),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              Text(
                user.username,
                style: GoogleFonts.openSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                user.email,
                style: GoogleFonts.openSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              // add rest all data in differnt listtiles

              ListTile(
                leading: const Icon(
                  Icons.phone,
                  color: Colors.greenAccent,
                ),
                title: Text(
                  user.contact,
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Divider(
                height: 10,
                thickness: 1,
              ),
              ListTile(
                leading: const Icon(
                  Icons.location_on,
                  color: Colors.blue,
                ),
                title: Text(
                  location,
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Divider(
                height: 10,
                thickness: 1,
              ),

              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(
                  "Sign Out",
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
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
