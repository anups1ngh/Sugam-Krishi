import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sugam_krishi/myCropsHandler.dart';
import 'package:sugam_krishi/resources/storage_methods.dart';
import 'package:sugam_krishi/models/user.dart' as model;

class AuthMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // get user details
  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(documentSnapshot);
  }

  String getCurrentUserUid() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      return user.uid;
    } else {
      // User is not logged in or authentication failed
      return '';
    }
  }

  String getCurrentUserUsername() {
    final User? user = FirebaseAuth.instance.currentUser;
    final String? username = user?.displayName;

    return username ?? '';
  }

  // Signing Up User

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String contact,
    required Uint8List file,
    required List<String> crops,
  }) async {
    String res = "Some error Occurred";

    print(crops);
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          contact.isNotEmpty ||
          file != null) {
        // registering user in auth with email and password
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', file, false, false);

        model.User _user = model.User(
          username: username,
          uid: cred.user!.uid,
          photoUrl: photoUrl,
          email: email,
          contact: contact,
          accHolderName: "",
          accNumber: "",
          ifscCode: "",
          crops: crops,
        );

        // adding user in our database
        await _firestore
            .collection("users")
            .doc(cred.user!.uid)
            .set(_user.toJson());

        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  // logging in user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        // logging in user with email and password
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
