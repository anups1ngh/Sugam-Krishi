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

import '../../weather/locationSystem.dart';

class addBankDetails extends StatefulWidget {
  final String userPhoto;
  final String userName;
  final String uid;
  const addBankDetails(
      {Key? key,
      required this.userPhoto,
      required this.userName,
      required this.uid})
      : super(key: key);

  @override
  State<addBankDetails> createState() => _addBankDetailsState();
}

class _addBankDetailsState extends State<addBankDetails> {
  bool isLoading = false;

  final TextEditingController accHolderNameController = TextEditingController();
  final TextEditingController accNumberController = TextEditingController();
  final TextEditingController accIfscController = TextEditingController();

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
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    accHolderNameController.dispose();
    accNumberController.dispose();
    accIfscController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return SafeArea(
        child: SingleChildScrollView(
            padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
        child: SingleChildScrollView(
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
                    onPressed: () async {
                      try {
                        if (accHolderNameController.text.isNotEmpty &&
                            accNumberController.text.isNotEmpty &&
                            accIfscController.text.isNotEmpty) {
                          setState(() {
                            isLoading = true;
                          });
                          String res =
                              await FireStoreMethods().updateBankDetails(
                            accHolderNameController.text,
                            accNumberController.text,
                            accIfscController.text,
                            widget.uid,
                          );
                          if (res == "success") {
                            setState(() {
                              isLoading = false;
                            });
                            showToastText("Bank Details Updated");
                            accHolderNameController.clear();
                            accNumberController.clear();
                            accIfscController.clear();
                            Navigator.pop(context);
                          } else {
                            setState(() {
                              isLoading = false;
                            });
                            showToastText("Something went wrong");
                          }
                        } else {
                          showToastText("Please fill all the fields");
                        }
                      } catch (e) {
                        setState(() {
                          isLoading = false;
                        });
                        showToastText(
                          e.toString(),
                        );
                      }
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
                            "Save",
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
              SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 6,
                      ),
                      child: TextField(
                        controller: accHolderNameController,
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
                          hintText: "Account Holder Name",
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 6,
                      ),
                      child: TextField(
                        controller: accNumberController,
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
                          hintText: "Enter Account Number",
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 6,
                      ),
                      child: TextField(
                        controller: accIfscController,
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
                          hintText: "Enter IFSC Code",
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )));
  }
}
