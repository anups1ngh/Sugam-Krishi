import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sugam_krishi/screens/FeedPage.dart';
import 'package:sugam_krishi/screens/HomePage.dart';
import 'package:sugam_krishi/screens/signupPage.dart';
import 'package:sugam_krishi/weather/ui/dummy.dart';
import '../weather/ui/detail_page.dart';
import 'signupPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  late String _phoneNumber;

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // Navigate to the OTP screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpPage(phoneNumber: _phoneController.text),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
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
              SizedBox(height: 50.0),
              Text(
                'Login',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 50.0),

              // SizedBox(height: 16.0),

              // SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter your phone number',
                    prefixIcon: Icon(Icons.phone),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey[400]!,
                      ),
                    ),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[400]!)),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 10) {
                      // return 'Please enter a valid phone number';
                    }
                    // TODO: Add phone number validation
                    return null;
                  },
                  onSaved: (value) => _phoneNumber = value!,
                ),
              ),
              SizedBox(height: 32.0),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: ElevatedButton(
                  child: Text('Login with OTP'),
                  onPressed: _handleSubmit,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: OutlinedButton(
                  child: Text('Don\'t have an account? Signup'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupPage()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class LoginPage extends StatefulWidget {
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _phoneController = TextEditingController();

//   void _handleSubmit() {
//     if (_formKey.currentState!.validate()) {
//       // Navigate to the OTP screen
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => OtpPage(phoneNumber: _phoneController.text),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Login'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               TextFormField(
//                 controller: _phoneController,
//                 keyboardType: TextInputType.phone,
//                 decoration: InputDecoration(
//                   labelText: 'Phone Number',
//                   prefixIcon: Icon(Icons.phone),
//                 ),
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return 'Please enter your phone number';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _handleSubmit,
//                 child: Text('Login'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class OtpPage extends StatelessWidget {
  final String phoneNumber;

  OtpPage({required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('OTP Verification'),
      // ),
      body: Column(
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
          SizedBox(height: 50.0),
          Text(
            'OTP Verification',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 50.0),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter OTP',
                prefixIcon: Icon(Icons.lock),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey[400]!,
                  ),
                ),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[400]!)),
              ),
            ),
          ),
          SizedBox(height: 32.0),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: ElevatedButton(
              child: Text('Let\'s go!'),
              onPressed: () {
                Fluttertoast.showToast(
                  msg: "Login Successful !",
                  toastLength: Toast.LENGTH_SHORT,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
