import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sugam_krishi/providers/user_provider.dart';
import 'package:sugam_krishi/resources/auth_methods.dart';
import 'package:sugam_krishi/resources/firestore_methods.dart';

import '../../utils/utils.dart';

class EditProfilePage extends StatefulWidget {
  final photoURL;
  final String location;
  final String contact;
  final String username;

  const EditProfilePage(
      {Key? key,
      this.photoURL,
      required this.location,
      required this.contact,
      required this.username})
      : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePage();
}

class _EditProfilePage extends State<EditProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _contactController;
  Uint8List? _image;
  bool photoSelected = false;
  bool _isLoading = false;
  AuthMethods _authMethods = AuthMethods();

  selectImage(ImageSource source) async {
    Uint8List im = await pickImage(source);
    // set state because we need to display the image we selected on the circle avatar
    setState(() {
      photoSelected = true;
      _image = im;
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

  @override
  void initState() {
    _usernameController = TextEditingController(text: widget.username);
    _contactController = TextEditingController(text: widget.contact);
    super.initState();
  }

  void updateDetails(Uint8List? img, String username, String contact) async {
    print("update function called");
    setState(() {
      _isLoading = true;
    });
    print(username);
    print(contact);
    String res = await FireStoreMethods().updateUserDetails(img!, username,
        contact, Provider.of<UserProvider>(context, listen: false).getUser.uid);
    if (res == "success") {
      setState(() {
        _isLoading = false;
      });
      showToastText("Profile updated");
    } else {
      setState(() {
        _isLoading = false;
      });
      // show the error
      showToastText(res);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE0F2F1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        // centerTitle: true,
        title: Text(
          "Edit Profile",
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
              SizedBox(
                height: 30,
              ),
              Stack(
                children: [
                  photoSelected
                      ? CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          radius: 64,
                          backgroundImage: MemoryImage(_image!),
                        )
                      : CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          radius: 64,
                          backgroundImage: NetworkImage(widget.photoURL),
                        ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.amberAccent.withOpacity(0.9),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          selectImage(ImageSource.gallery);
                        },
                        child: Icon(
                          Icons.add_a_photo_rounded,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                textAlign: TextAlign.center,
                controller: _usernameController,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                ),
                decoration: InputDecoration(
                  // focusedBorder: OutlineInputBorder(
                  //   borderRadius: BorderRadius.circular(12),
                  //   borderSide: BorderSide(
                  //       color: Colors.teal.shade400,
                  //       width: 0.4
                  //   ),
                  // ),
                  border: InputBorder.none,
                  // border: OutlineInputBorder(
                  //   borderRadius: BorderRadius.circular(12),
                  //   borderSide: BorderSide(
                  //       color: Colors.teal.shade400,
                  //       width: 0.4
                  //   ),
                  // ),
                  //   enabledBorder: OutlineInputBorder(
                  //     borderRadius: BorderRadius.circular(12),
                  //     borderSide: BorderSide(
                  //         color: Colors.teal.shade400,
                  //         width: 0.4
                  //     ),
                  //   ),
                  hintText: "Username",
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(
                width: 150,
                height: 42,
              ),
              SizedBox(
                height: 10,
              ),

              //MENU
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Colors.teal.shade400,
                      width: 0.4,
                    ),
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
                  title: TextField(
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      // fillColor: Colors.teal.shade50,
                      // filled: true,
                      border: InputBorder.none,
                      // border: OutlineInputBorder(
                      //   borderRadius: BorderRadius.circular(20),
                      //   borderSide: BorderSide(
                      //       color: Colors.teal.shade400,
                      //       width: 0.2,
                      //   ),
                      // ),
                      // enabledBorder: OutlineInputBorder(
                      //   borderRadius: BorderRadius.circular(20),
                      //   borderSide: BorderSide(
                      //     color: Colors.teal.shade400,
                      //     width: 0.4,
                      //   ),
                      // ),
                      // focusedBorder: OutlineInputBorder(
                      //   borderRadius: BorderRadius.circular(20),
                      //   borderSide: BorderSide(
                      //     color: Colors.teal.shade400,
                      //     width: 0.4,
                      //   ),
                      // ),
                      hintText: "Contact No.",
                    ),
                    controller: _contactController,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Opacity(
                  opacity: 0.5,
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: Colors.teal.shade400.withOpacity(0.5),
                          width: 0.4),
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
                      widget.location,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: 10,
              ),
              //UPDATE BUTTON
              SizedBox(
                width: 150,
                height: 42,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.amberAccent,
                  ),
                  onPressed: () {
                    print(_usernameController.text);
                    print(_contactController.text.replaceAll(" ", ""));
                    // await _authMethods.updateUserDetails(
                    //     _image,
                    //     _usernameController.text,
                    //     _contactController.text.replaceAll(" ", ""),
                    // );
                    // Navigator.pop(context);
                    updateDetails(_image!, _usernameController.text,
                        _contactController.text.replaceAll(" ", ""));
                    Navigator.pop(context);
                  },
                  child: _isLoading
                      ? CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          "Update Profile",
                          style: GoogleFonts.openSans(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
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
