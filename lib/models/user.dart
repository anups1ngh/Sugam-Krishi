import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sugam_krishi/models/cartItem.dart';

class User {
  final String email;
  final String uid;
  final String photoUrl;
  final String username;
  final String contact;
  final String accHolderName;
  final String accNumber;
  final String ifscCode;

  const User({
    required this.username,
    required this.uid,
    required this.photoUrl,
    required this.email,
    required this.contact,
    this.accHolderName = "ACCOUNTHOLDERNAME",
    this.accNumber = "9999999999999",
    this.ifscCode = "VHDBVUS9278BDHIK",
  });

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      username: snapshot["username"],
      uid: snapshot["uid"],
      email: snapshot["email"],
      photoUrl: snapshot["photoUrl"],
      contact: snapshot["contact"],
      accHolderName: snapshot["accHolderName"] ?? "ACCOUNTHOLDERNAME",
      accNumber: snapshot["accNumber"] ?? "9999999999999",
      ifscCode: snapshot["ifscCode"] ?? "VHDBVUS9278BDHIK",
    );
  }

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "email": email,
        "photoUrl": photoUrl,
        "contact": contact,
        "accHolderName": accHolderName,
        "accNumber": accNumber,
        "ifscCode": ifscCode,
      };
}
