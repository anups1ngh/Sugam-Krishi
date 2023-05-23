import 'package:cloud_firestore/cloud_firestore.dart';

class MarketPlace {
  String? description;
  final String uid;
  final String username;
  final String postId;
  final String category;
  final DateTime datePublished;
  String? postUrl;
  final String profImage;
  final String price;
  final String location;
  final String contact;
  final String itemName;
  String? quantity;
  final String unit;

  MarketPlace({
    this.description,
    required this.uid,
    required this.username,
    required this.postId,
    required this.category,
    required this.datePublished,
    this.postUrl,
    required this.profImage,
    required this.price,
    required this.location,
    required this.contact,
    required this.itemName,
    this.quantity,
    required this.unit,
  });

  static MarketPlace fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return MarketPlace(
      description: snapshot["description"],
      uid: snapshot["uid"],
      username: snapshot["username"],
      postId: snapshot["postId"],
      category: snapshot["category"],
      datePublished: snapshot["datePublished"],
      postUrl: snapshot['postUrl'],
      profImage: snapshot['profImage'],
      price: snapshot['price'],
      location: snapshot['location'],
      contact: snapshot['contact'],
      itemName: snapshot['itemName'],
      quantity: snapshot['quantity'],
      unit: snapshot['unit'],
    );
  }

  Map<String, dynamic> toJson() => {
        "description": description,
        "uid": uid,
        "username": username,
        "postId": postId,
        "category": category,
        "datePublished": datePublished,
        'postUrl': postUrl,
        'profImage': profImage,
        'price': price,
        'location': location,
        'contact': contact,
        'itemName': itemName,
        'quantity': quantity,
        'unit': unit,
      };
}
