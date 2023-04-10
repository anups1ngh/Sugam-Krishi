import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sugam_krishi/resources/auth_methods.dart';
import 'package:sugam_krishi/screens/HomePage.dart';
import 'package:sugam_krishi/screens/loginPage.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String _email = '';
  String _password = '';
  String _username = '';
  String _contact = '';
  TextEditingController phoneController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  RegExp regex = RegExp(r'^(?=.*?[0-9])(?=.*?[!@#\$&*~]).{6,}$');
  double screenHeight = 0;
  double screenWidth = 0;
  double bottom = 0;
  String countryDial = "+91";
  bool isLoading = false;

  Uint8List? _image;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void signUpUser(String email, String password, String username,
      String contact, Uint8List? image) async {
    final ByteData bytes = await rootBundle.load('assets/farmer.png');
    image = bytes.buffer.asUint8List();
    // set loading to true
    setState(() {
      isLoading = true;
    });

    // signup user using our authmethodds
    String res = await AuthMethods().signUpUser(
        email: email,
        password: password,
        username: username,
        contact: contact,
        file: image);
    // if string returned is sucess, user has been created
    if (res == "success") {
      setState(() {
        isLoading = false;
      });
      showToastText("Account created successfully");
      // navigate to the home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } else {
      setState(() {
        isLoading = false;
      });
      // show the error
      showToastText(res);
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    bottom = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.zero,
                  // color: Colors.yellow,
                  height: MediaQuery.of(context).size.width * 0.7,
                  child: ClipPath(
                    clipper: OvalBottomBorderClipper(),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/signup_illustration.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Add other widgets as necessary
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: screenWidth / 12,
                    right: screenWidth / 12,
                    top: screenHeight / 12,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 6,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your username';
                          }
                          if (value.length < 3) {
                            showToastText(
                                'Username should be atleast 3 characters long');
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _username = value!;
                        },
                        decoration: InputDecoration(
                          labelText: 'Username',
                          hintText: 'Enter your username',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(value)) {
                            showToastText('Please enter a valid email');
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _email = value!;
                        },
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (!regex.hasMatch(value)) {
                            showToastText(
                                'Password should be atleast 6 characters long and should contain atleast one special character and one number');
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _password = value!;
                        },
                        obscureText: true,
                        obscuringCharacter: '*',
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          prefixIcon: Icon(FontAwesomeIcons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      IntlPhoneField(
                        controller: phoneController,
                        validator: (value) {
                          if (phoneController.text.isEmpty) {
                            showToastText('Please enter your phone number');
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _contact = value!.completeNumber;
                        },
                        showCountryFlag: false,
                        showDropdownIcon: false,
                        initialValue: countryDial,
                        onCountryChanged: (country) {
                          setState(() {
                            countryDial = "+" + country.dialCode;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Phone number',
                          hintText: 'Enter your phone number',
                          prefixIcon: Icon(FontAwesomeIcons.mobile),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            setState(() {
                              isLoading = true;
                            });
                            signUpUser(
                                _email, _password, _username, _contact, _image);
                            Future.delayed(Duration(seconds: 2), () {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: ((context) => HomePage())));
                            });
                          }
                        },
                        child: Container(
                          height: 50,
                          width: screenWidth,
                          // margin: EdgeInsets.only(bottom: screenHeight / 12),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Center(
                            child: isLoading
                                ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    "SIGNUP",
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                      fontSize: 18,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: OutlinedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white),
                              minimumSize: MaterialStateProperty.all(
                                  Size(screenWidth, 50)),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()),
                              );
                            },
                            child: Text("Already have an account? Login")),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
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
}
