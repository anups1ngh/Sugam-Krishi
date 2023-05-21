import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String sellerUid;
  final String sellerUsername;
  final String postId;
  final String postUrl;
  final int cost;
  final String itemName;
  int? quantity;
  final String buyerName;
  final String buyerLocation;
  final String buyerUid;
  final int price;

  CartItem({
    required this.sellerUid,
    required this.sellerUsername,
    required this.postId,
    required this.postUrl,
    required this.cost,
    required this.itemName,
    this.quantity,
    required this.buyerName,
    required this.buyerLocation,
    required this.buyerUid,
    required this.price,
  });

  static CartItem fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return CartItem(
      sellerUid: snapshot["sellerUid"],
      sellerUsername: snapshot["sellerUsername"],
      postId: snapshot["postId"],
      postUrl: snapshot["postUrl"],
      cost: snapshot["cost"],
      itemName: snapshot["itemName"],
      quantity: snapshot["quantity"], // Convert to String
      buyerName: snapshot["buyerName"],
      buyerLocation: snapshot["buyerLocation"],
      buyerUid: snapshot["buyerUid"],
      price: snapshot["price"],
    );
  }

  Map<String, dynamic> toJson() => {
        "sellerUid": sellerUid,
        "sellerUsername": sellerUsername,
        "postId": postId,
        "postUrl": postUrl,
        "cost": cost,
        "itemName": itemName,
        "quantity": quantity, // Store as String
        "buyerName": buyerName,
        "buyerLocation": buyerLocation,
        "buyerUid": buyerUid,
        "price": price,
      };
}
