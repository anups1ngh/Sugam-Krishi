import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String profilePic;
  final String name;
  final String uid;
  final String text;
  final String location;
  final String commentId;
  final DateTime datePublished;

  Comment({
    required this.profilePic,
    required this.name,
    required this.uid,
    required this.text,
    required this.location,
    required this.commentId,
    required this.datePublished,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Comment(
      profilePic: data['profilePic'],
      name: data['name'],
      uid: data['uid'],
      text: data['text'],
      location: data['location'],
      commentId: data['commentId'],
      datePublished: data['datePublished'].toDate(),
    );
  }
}