import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'loginPage.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  late String _username;
  late String _email;
  late String _password;
  late String _phoneNumber;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, do something here
      print('Username: $_username');
      print('Email: $_email');
      print('Password: $_password');
      print('Phone Number: $_phoneNumber');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // SizedBox(height: 50.0),
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

                SizedBox(height: 50.0),
                // Image.asset(
                //   'assets/signup_illustration.jpg',
                //   height: 200.0,
                // ),
                Text(
                  'Sugam Krishi',
                  style: TextStyle(
                    fontFamily: 'Pacifico',
                    fontSize: 36.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 50.0),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Username',
                      hintText: 'Enter your username',
                      prefixIcon: Icon(Icons.person),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey[400]!,
                        ),
                      ),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[400]!)),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a username';
                      }
                      // TODO: Add username validation
                      return null;
                    },
                    onSaved: (value) => _username = value!,
                  ),
                ),
                SizedBox(height: 16.0),

                // SizedBox(height: 16.0),

                SizedBox(height: 16.0),
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
                      if (value!.isEmpty) {
                        return 'Please enter a phone number';
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
                    child: Text('Signup'),
                    onPressed: _submit,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: OutlinedButton(
                    child: Text('Already have an account? Login'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
