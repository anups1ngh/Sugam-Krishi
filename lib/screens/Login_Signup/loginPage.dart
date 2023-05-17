import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sugam_krishi/resources/auth_methods.dart';
import 'package:sugam_krishi/screens/HomePage.dart';
import 'package:sugam_krishi/screens/Login_Signup/loginPage.dart';
import 'package:sugam_krishi/screens/Login_Signup/signupPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _email = '';
  String _password = '';
  final _formKey = GlobalKey<FormState>();

  double screenHeight = 0;
  double screenWidth = 0;
  double bottom = 0;
  String countryDial = "+91";
  bool isLoading = false;

  void loginUser(String email, String password) async {
    setState(() {
      isLoading = true;
    });
    String res =
        await AuthMethods().loginUser(email: email, password: password);
    if (res == 'success') {
      setState(() {
        isLoading = false;
      });
      showToastText('Login Successful');
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
          (route) => false);
    } else {
      setState(() {
        isLoading = false;
      });
      showToastText(res);
    }
  }

  // Future<void> loginWithEmailPassword(String email, String password) async {
  //   try {
  //     UserCredential userCredential =
  //         await FirebaseAuth.instance.signInWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     // The user is signed in
  //     setState(() {
  //       isLoading = false;
  //     });
  //     showToastText('Login Successful');
  //     Navigator.of(context).pushReplacement(
  //         MaterialPageRoute(builder: ((context) => HomePage())));
  //   } on FirebaseAuthException catch (e) {
  //     // Handle sign in errors
  //     setState(() {
  //       isLoading = false;
  //     });
  //     if (e.code == 'user-not-found') {
  //       showToastText('No user found for that email.');
  //     } else if (e.code == 'wrong-password') {
  //       showToastText('Wrong password provided for that user.');
  //     }
  //   }
  // }

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
                            'assets/login_illustration.jpg',
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
                    // top: bottom > 0 ? screenHeight / 12 : 0,
                  ),
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
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
                        height: 16,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your password';
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
                      SizedBox(
                        height: 35,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            setState(() {
                              isLoading = true;
                            });
                            loginUser(_email, _password);
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
                                    "LOGIN",
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
                                    builder: (context) => RegisterScreen()),
                              );
                            },
                            child: Text("Don't have an account? Register")),
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
