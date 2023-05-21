import 'package:flutter/widgets.dart';
import 'package:sugam_krishi/models/user.dart';
import 'package:sugam_krishi/resources/auth_methods.dart';

class UserProvider with ChangeNotifier {
  User _user = User(
    token: "",
    username: "",
    uid: "-1",
    email: "",
    photoUrl: "",
    contact: "",
  );
  final AuthMethods _authMethods = AuthMethods();

  User get getUser => _user;

  Future<void> refreshUser() async {
    User user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
}
