import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sugam_krishi/models/cartItem.dart';
import 'package:sugam_krishi/models/marketplace.dart';
import 'package:sugam_krishi/models/post.dart';
import 'package:sugam_krishi/resources/auth_methods.dart';
import 'package:sugam_krishi/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> updateUserDetails(
      {required Uint8List img,
      required String username,
      required String contact,
      required String uid}) async {
    // User currentUser = _auth.currentUser!;
    String res = "Some error Occurred";
    try {
      String photoUrl = await StorageMethods()
          .uploadImageToStorage('profilePics', img, false, false);
      // model.User _user = model.User(
      //   username: username,
      //   uid: currentUser.uid,
      //   photoUrl: photoUrl,
      //   email: currentUser.email!,
      //   contact: contact,
      // );
      await _firestore.collection("users").doc(uid).update({
        "username": username,
        "photoUrl": photoUrl,
        "contact": contact,
      });
      // .set(_user.toJson());
      //return _user;
      res = "success";
    } catch (e) {
      return e.toString();
    }
    return res;
  }

  // add CRUD methods here for cartItems
  Future<String> addCartItem(
      String sellerUid,
      String sellerUsername,
      String postId,
      String postUrl,
      int cost,
      String itemName,
      int quantity,
      String buyerName,
      String buyerLocation,
      String buyerUid,
      int price) async {
    String res = "Some error occurred";
    try {
      print("Inside addCartItem");
      // create a new collection cart under collection = users and doc = buyerUid and insert these values there
      CartItem cartItem = CartItem(
        sellerUid: sellerUid,
        sellerUsername: sellerUsername,
        postId: postId,
        postUrl: postUrl,
        cost: cost,
        itemName: itemName,
        quantity: quantity,
        buyerName: buyerName,
        buyerLocation: buyerLocation,
        buyerUid: buyerUid,
        price: price,
      );
      final cartItemMap = cartItem.toJson();
// create a new collection cart under collection = users and doc = buyerUid and insert these values there
      final DocumentReference cartDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(buyerUid)
          .collection('cart')
          .doc(postId);

      await cartDocRef.set(cartItemMap);

      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> updateCartItemQuantity(
      String buyerUid, String postId, int quantity, int price) async {
    final DocumentReference cartDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(buyerUid)
        .collection('cart')
        .doc(postId);

    final DocumentSnapshot cartSnapshot = await cartDocRef.get();
    if (!cartSnapshot.exists) {
      // Cart item does not exist
      return;
    }

    final Map<String, dynamic>? cartData =
    cartSnapshot.data() as Map<String, dynamic>?;

    if (cartData != null) {
      final int existingQuantity = quantity;
      final int newQuantity = existingQuantity;
      final int existingPrice = price;
      final int newCost = existingPrice * newQuantity;

      await cartDocRef.update({
        'quantity': newQuantity,
        'cost': newCost,
      });
    }
  }

  Future<void> incrementCartItemQuantity(
      String buyerUid, String postId, int? quantity, int price) async {
    final DocumentReference cartDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(buyerUid)
        .collection('cart')
        .doc(postId);

    final DocumentSnapshot cartSnapshot = await cartDocRef.get();
    if (!cartSnapshot.exists) {
      // Cart item does not exist
      return;
    }

    final Map<String, dynamic>? cartData =
        cartSnapshot.data() as Map<String, dynamic>?;

    if (cartData != null) {
      final int existingQuantity = quantity!;
      final int newQuantity = existingQuantity + 1;
      final int existingPrice = price;
      final int newCost = existingPrice * newQuantity;

      await cartDocRef.update({
        'quantity': newQuantity,
        'cost': newCost,
      });
    }
  }

  Future<void> decrementCartItemQuantity(
      String buyerUid, String postId, int? quantity, int price) async {
    final DocumentReference cartDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(buyerUid)
        .collection('cart')
        .doc(postId);

    final DocumentSnapshot cartSnapshot = await cartDocRef.get();
    if (!cartSnapshot.exists) {
      // Cart item does not exist
      return;
    }

    final Map<String, dynamic>? cartData =
        cartSnapshot.data() as Map<String, dynamic>?;

    if (cartData != null) {
      final int existingQuantity = quantity!;
      if (existingQuantity > 0) {
        final int newQuantity = existingQuantity - 1;
        if(newQuantity == 0){

        }
        final int existingPrice = price;
        final int newCost = existingPrice * newQuantity;

        await cartDocRef.update({
          'quantity': newQuantity,
          'cost': newCost,
        });
      }
    }
  }

  Future<void> removeCartItem(String buyerUid, String postId) async {
    final DocumentReference cartDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(buyerUid)
        .collection('cart')
        .doc(postId);

    await cartDocRef.delete();
  }

  Future<String> updateBankDetails(String accHolderName, String accNumber,
      String ifscCode, String uid) async {
    final usersCollection = FirebaseFirestore.instance.collection('users');
    final userDoc = usersCollection.doc(uid);
    String res = "Some error Occurred";
    try {
      await userDoc.update({
        'accHolderName': accHolderName,
        'accNumber': accNumber,
        'ifscCode': ifscCode,
      });
      res = "success";
    } catch (e) {
      return e.toString();
    }
    return res;
  }

  Future<String> uploadPost(String description, Uint8List? file, String uid,
      String username, String profImage, String location) async {
    // asking uid here because we dont want to make extra calls to firebase auth when we can just get from our state management
    String res = "Some error occurred";
    try {
      String photoUrl = file == null
          ? ""
          : await StorageMethods()
              .uploadImageToStorage('posts', file, true, false);

      String postId = const Uuid().v1(); // creates unique id based on time
      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        likes: [],
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profImage: profImage,
        location: location,
      );
      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> uploadMarketplaceItem(
      {String? description,
      required String uid,
      required String username,
      required String category,
      Uint8List? file,
      required String profImage,
      required String price,
      required String location,
      required String contact,
      required String itemName,
      String? quantity}) async {
    String res = "Some error occurred";
    try {
      String photoUrl = file == null
          ? ""
          : await StorageMethods()
              .uploadImageToStorage('marketplace', file, false, true);
      String postId = const Uuid().v1(); // creates unique id based on time
      MarketPlace marketPlace = MarketPlace(
        description: description,
        uid: uid,
        username: username,
        postId: postId,
        category: category,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profImage: profImage,
        price: price,
        location: location,
        contact: contact,
        itemName: itemName,
        quantity: quantity,
      );
      _firestore
          .collection('marketplace')
          .doc(postId)
          .set(marketPlace.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> likePost(String postId, String uid, List likes) async {
    String res = "Some error occurred";
    try {
      if (likes.contains(uid)) {
        // if the likes list contains the user uid, we need to remove it
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        // else we need to add uid to the likes array
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Post comment
  Future<String> postComment(String postId, String text, String uid,
      String name, String profilePic, String location) async {
    String res = "Some error occurred";
    print("In FIrestore");
    try {
      if (text.isNotEmpty) {
        // if the likes list contains the user uid, we need to remove it
        String commentId = const Uuid().v1();
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
          'location': location,
        });
        res = 'success';
      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
    }
    print(res);
    return res;
  }

  // Delete Post
  Future<String> deletePost(String postId) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('posts').doc(postId).delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
