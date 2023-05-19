import 'package:flutter/services.dart';
import '../../resources/auth_methods.dart';
import '../../utils/utils.dart';


class SignupHandler{
  static String email = "";
  static String password = "";
  static String username = "";
  static String contact = "";
  static Uint8List image = Uint8List(0);
  static List<String> crops = [];
  // static Future<void> signUpUser(SignupData signupData) async {
  //   // final ByteData bytes = await rootBundle.load(localImagePath);
  //   // image = bytes.buffer.asUint8List();
  //   // set loading to true
  //   setState(() {
  //     isLoading = true;
  //   }
  //   );
  //
  //   // signup user using our authmethodds
  //   String res = await AuthMethods().signUpUser(
  //       email: email,
  //       password: password,
  //       username: username,
  //       contact: contact,
  //       file: image
  //   );
  //   // if string returned is sucess, user has been created
  //   if (res == "success") {
  //     setState(() {
  //       isLoading = false;
  //     });
  //     showToastText("Account created successfully");
  //     // navigate to the home screen
  //     Navigator.of(context).pushReplacement(
  //       MaterialPageRoute(
  //         builder: (context) => HomePage(),
  //       ),
  //     );
  //   } else {
  //     setState(() {
  //       isLoading = false;
  //     });
  //     // show the error
  //     showToastText(res);
  //   }
  // }
}