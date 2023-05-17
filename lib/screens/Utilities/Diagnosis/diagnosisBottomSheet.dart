import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sugam_krishi/constants.dart';
import 'package:sugam_krishi/providers/user_provider.dart';

import '../../../resources/firestore_methods.dart';
import '../../../weather/locationSystem.dart';

class diagnosisSheet extends StatefulWidget {
  final String userPhoto;
  final String userName;
  final String diseaseName;
  final Uint8List? image;
  const diagnosisSheet(
      {super.key,
      required this.userPhoto,
      required this.userName,
      required this.diseaseName,
      required this.image});

  @override
  State<diagnosisSheet> createState() => _diagnosisSheetState();
}

class _diagnosisSheetState extends State<diagnosisSheet> {
  late TextEditingController _descriptionController;
  //final Constants _constants = Constants();
  String _shareTo = "Anyone";
  bool isLoading = false;
  String res = "";
  String location = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _descriptionController = TextEditingController(text: widget.diseaseName);
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

// In post image function make it such that if we do not select an image then it will upload the post then also
  void postImageDiagnosis(String uid, String username, String profImage) async {
    // final ByteData bytes =
    //     await rootBundle.load('assets/login_illustration.jpg');
    // _img = bytes.buffer.asUint8List();
    LocationSystem.getPosition();
    setState(() {
      isLoading = true;
    });
    // start the loading
    try {
      // upload to storage and db
      if (widget.image != null) {
        res = await FireStoreMethods().uploadPost(
          _descriptionController.text,
          widget.image!,
          uid,
          username,
          profImage,
          location,
        );
      } else {
        res = await FireStoreMethods().uploadPost(
          _descriptionController.text,
          null,
          uid,
          username,
          profImage,
          location,
        );
      }

      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        showToastText(
          'Posted!',
        );
        _descriptionController.clear();
        Navigator.pop(context);
      } else {
        showToastText(res);
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showToastText(
        err.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        // reverse: true,
        child: Container(
          // height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            // gradient: _constants.linearGradientTeal,
            color: Color(0xffE0F2F1),
            boxShadow: [
              // BoxShadow(
              //   color: _constants.primaryColor.withOpacity(.2),
              //   spreadRadius: 5,
              //   blurRadius: 7,
              //   offset: const Offset(0, 3),
              // ),
            ],
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18), topRight: Radius.circular(18)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
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
                        backgroundColor: MaterialStateProperty.all(
                            Colors.greenAccent.shade700),
                      ),
                      onPressed: () {
                        if (_descriptionController.text.isNotEmpty) {
                          postImageDiagnosis(
                            userProvider.getUser.uid,
                            userProvider.getUser.username,
                            userProvider.getUser.photoUrl,
                          );
                        }
                      },
                      child: isLoading
                          ? SpinKitThreeBounce(
                              color: Colors.white,
                              size: 18,
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
                TextField(
                  maxLines: 10,
                  controller: _descriptionController,
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
                    hintText: "Write something",
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
