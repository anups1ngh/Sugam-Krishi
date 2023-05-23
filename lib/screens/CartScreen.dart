import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sugam_krishi/models/cartItem.dart';
import 'package:sugam_krishi/providers/user_provider.dart';
import 'package:sugam_krishi/resources/auth_methods.dart';
import 'package:sugam_krishi/resources/firestore_methods.dart';
import 'package:sugam_krishi/screens/Marketplace/MarketplacePage.dart';
import 'package:sugam_krishi/utils/utils.dart';
import 'package:sugam_krishi/models/user.dart' as model;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

double calculateSubtotal(List<CartItem> cartItems) {
  double subtotal = 0;
  for (var item in cartItems) {
    double price = double.parse(item.price.toString());
    int quantity = int.parse(item.quantity.toString() ?? "0");
    subtotal += price * quantity;
  }
  return subtotal;
}

double calculateDeliveryFee(double subtotal) {
  if (subtotal < 500) {
    return 500 - subtotal;
  } else {
    return 0;
  }
}

double calculateTotal(double subtotal, double deliveryFee) {
  return subtotal + deliveryFee;
}

class _CartScreenState extends State<CartScreen> {
  Razorpay? _razorpay;
  int amount = 0;
  Map<String, int> cartItems = {};
  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay?.clear();
  }

  void getTokenFromFirestore(
      String uid, Function(String) onTokenReceived) async {
    try {
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        String token = data['token'];
        onTokenReceived(token);
      }
    } catch (e) {
      print('Error getting token from Firestore: $e');
      onTokenReceived('');
    }
  }

  void sendPushMessage(String token, String body, String title) async {
    try {
      await http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAcZBIsxQ:APA91bElW_KXwkuf1aBEWsLhhgkNT9aKMODqtab8gI2eNwlQ3d52lSHruSW_5mzzOKLspu4G8jlgjGxI8s-ysnVsrrUhJl8D9ocHRdCUori1-Wp5wJIEE9viIyc2bxCBvNda5E3UXDLA',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': body,
              'title': title,
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done',
            },
            'to': token,
          },
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  void onPaymentSuccess() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(AuthMethods().getCurrentUserUid())
        .collection('cart')
        .get()
        .then((querySnapshot) {
      Map<String, int> cartItems = {};

      querySnapshot.docs.forEach((doc) {
        int currentQuantity = doc.data()['quantity'];
        String postId = doc.data()['postId'];
        String sellerUid = doc.data()['sellerUid'];
        String postUrl = doc.data()['postUrl'];
        int cost = doc.data()['cost'];
        String itemName = doc.data()['itemName'];
        String buyerName = doc.data()['buyerName'];
        String buyerLocation = doc.data()['buyerLocation'];
        String buyerUid = doc.data()['buyerUid'];
        int quantity = doc.data()['quantity'];
        String orderId = const Uuid().v1();
        String token = '';

        FirebaseFirestore.instance
            .collection('users')
            .doc(sellerUid)
            .collection('orders')
            .doc(orderId)
            .set({
          'postId': postId,
          'sellerUid': sellerUid,
          'postUrl': postUrl,
          'cost': cost,
          'itemName': itemName,
          'buyerName': buyerName,
          'buyerLocation': buyerLocation,
          'buyerUid': buyerUid,
          'quantity': quantity,
          'orderId': orderId,
          'status': 'pending',
        });

        getTokenFromFirestore(sellerUid, (receivedToken) {
          token = receivedToken;
          sendPushMessage(
              token,
              'You have a new order for $itemName from $buyerName',
              'New Order');
        });

        cartItems[postId] = currentQuantity;

        FirebaseFirestore.instance
            .collection('marketplace')
            .doc(postId)
            .get()
            .then((marketplaceDoc) {
          if (marketplaceDoc.exists) {
            int marketplaceQuantity =
                int.parse(marketplaceDoc.data()!['quantity'].toString());
            int updatedMarketplaceQuantity =
                marketplaceQuantity - currentQuantity;

            if (updatedMarketplaceQuantity <= 0) {
              FirebaseFirestore.instance
                  .collection('marketplace')
                  .doc(postId)
                  .delete();
            } else {
              FirebaseFirestore.instance
                  .collection('marketplace')
                  .doc(postId)
                  .update({'quantity': updatedMarketplaceQuantity});
            }
          }
        });
      });

      querySnapshot.docs.forEach((doc) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(AuthMethods().getCurrentUserUid())
            .collection('cart')
            .doc(doc.id)
            .delete();
      });

      // Use the cartItems map as needed (e.g., store it in a user's order history)
      print(cartItems);
    });
  }

  void openPaymentPortal({required String name, required String contact, required String email, required int total}) async {
    print("Making payment");
    var options = {
      'key': 'rzp_test_l6N7mjNyhTQJUs',
      'amount': total,
      'name': name,
      'currency': 'INR',
      'description': 'Payment',
      'prefill': {'contact': contact, 'email': email},
      'external': {
        'wallets': ['paytm']
      }
    };
    try {
      _razorpay?.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
        msg: "Payment Successful🥳: ${response.paymentId}",
        timeInSecForIosWeb: 2);
    onPaymentSuccess();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
        msg: "Payment Failed: ${response.code} - ${response.message}",
        timeInSecForIosWeb: 2);

    print("Failed: ${response.code} - ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
        msg: "EXTERNAL_WALLET IS : ${response.walletName}",
        timeInSecForIosWeb: 4);
  }

  @override
  Widget build(BuildContext context) {
    model.User user = Provider.of<UserProvider>(context).getUser;
    // String userUid = user.uid;
    return Scaffold(
      backgroundColor: Color(0xffE0F2F1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Text(
          "Cart",
          textAlign: TextAlign.left,
          style: GoogleFonts.openSans(
            color: Colors.black,
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.greenAccent.shade700,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(AuthMethods().getCurrentUserUid())
                    .collection('cart')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<CartItem> cartItems = snapshot.data!.docs
                        .map((doc) => CartItem.fromSnap(doc))
                        .toList();
                    double subtotal = calculateSubtotal(cartItems);
                    return Text(
                      '₹ ${subtotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
              FilledButton(
                onPressed: (){
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(AuthMethods().getCurrentUserUid())
                      .collection('cart')
                      .get()
                      .then((snapshot) {
                    if (snapshot.docs.isNotEmpty) {
                      List<CartItem> cartItems = snapshot.docs
                          .map((doc) => CartItem.fromSnap(doc))
                          .toList();
                      double subtotal = calculateSubtotal(cartItems);
                      double deliveryFee = calculateDeliveryFee(subtotal);
                      double total = calculateTotal(subtotal, deliveryFee);
                      setState(() {
                        amount = (total * 100).toInt();
                      });
                      print(amount);
                      openPaymentPortal(
                        name: user.username,
                        contact: user.contact,
                        email: user.email,
                        total: amount,
                      );
                    }
                  });
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.greenAccent.shade700,
                  fixedSize: Size(200, 50),
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5)
                ),
                child: Text(
                  "Checkout",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        edgeOffset: 40,
        strokeWidth: 2.5,
        color: Color(0xff0ba99b),
        onRefresh: () async {
          await Future.delayed(Duration(milliseconds: 800));
          setState(() {});
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(AuthMethods().getCurrentUserUid())
                            .collection('cart')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<CartItem> cartItems = snapshot.data!.docs
                                .map((doc) => CartItem.fromSnap(doc))
                                .toList();
                            return ListView.builder(
                              itemCount: cartItems.length,
                              itemBuilder: (context, index) {
                                return CartProductCard(
                                  product: cartItems[index],
                                );
                              },
                            );
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Column(
              //   children: [
              //     Divider(
              //       thickness: 2,
              //     ),
              //     Padding(
              //       padding: const EdgeInsets.symmetric(
              //           horizontal: 40.0, vertical: 10),
              //       child: Column(
              //         children: [
              //           Row(
              //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //             children: [
              //               Text(
              //                 "Subtotal",
              //                 style: TextStyle(
              //                   fontSize: 20,
              //                 ),
              //               ),
              //               StreamBuilder<QuerySnapshot>(
              //                 stream: FirebaseFirestore.instance
              //                     .collection('users')
              //                     .doc(AuthMethods().getCurrentUserUid())
              //                     .collection('cart')
              //                     .snapshots(),
              //                 builder: (context, snapshot) {
              //                   if (snapshot.hasData) {
              //                     List<CartItem> cartItems = snapshot.data!.docs
              //                         .map((doc) => CartItem.fromSnap(doc))
              //                         .toList();
              //                     double subtotal = calculateSubtotal(cartItems);
              //                     return Text(
              //                       '₹${subtotal.toStringAsFixed(2)}',
              //                       style: Theme.of(context).textTheme.headline5,
              //                     );
              //                   } else {
              //                     return CircularProgressIndicator();
              //                   }
              //                 },
              //               ),
              //             ],
              //           ),
              //           SizedBox(height: 10),
              //           Row(
              //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //             children: [
              //               Text(
              //                 "Delivery Fee",
              //                 style: Theme.of(context).textTheme.headline5,
              //               ),
              //               StreamBuilder<QuerySnapshot>(
              //                 stream: FirebaseFirestore.instance
              //                     .collection('users')
              //                     .doc(AuthMethods().getCurrentUserUid())
              //                     .collection('cart')
              //                     .snapshots(),
              //                 builder: (context, snapshot) {
              //                   if (snapshot.hasData) {
              //                     List<CartItem> cartItems = snapshot.data!.docs
              //                         .map((doc) => CartItem.fromSnap(doc))
              //                         .toList();
              //                     double subtotal = calculateSubtotal(cartItems);
              //                     double deliveryFee =
              //                         calculateDeliveryFee(subtotal);
              //                     return Text(
              //                       '₹${deliveryFee.toStringAsFixed(2)}',
              //                       style: Theme.of(context).textTheme.headline5,
              //                     );
              //                   } else {
              //                     return CircularProgressIndicator();
              //                   }
              //                 },
              //               ),
              //             ],
              //           ),
              //         ],
              //       ),
              //     ),
              //     Stack(
              //       children: [
              //         Container(
              //           width: MediaQuery.of(context).size.width,
              //           height: 60,
              //           decoration: BoxDecoration(
              //             color: Colors.black.withAlpha(50),
              //           ),
              //         ),
              //         Container(
              //           width: MediaQuery.of(context).size.width,
              //           margin: const EdgeInsets.all(5),
              //           height: 50,
              //           decoration: BoxDecoration(
              //             color: Colors.black,
              //           ),
              //           child: Padding(
              //             padding: const EdgeInsets.symmetric(horizontal: 30.0),
              //             child: Row(
              //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //               children: [
              //                 Text(
              //                   "Total",
              //                   style: Theme.of(context)
              //                       .textTheme
              //                       .headline5!
              //                       .copyWith(color: Colors.white),
              //                 ),
              //                 StreamBuilder<QuerySnapshot>(
              //                   stream: FirebaseFirestore.instance
              //                       .collection('users')
              //                       .doc(AuthMethods().getCurrentUserUid())
              //                       .collection('cart')
              //                       .snapshots(),
              //                   builder: (context, snapshot) {
              //                     if (snapshot.hasData) {
              //                       List<CartItem> cartItems = snapshot.data!.docs
              //                           .map((doc) => CartItem.fromSnap(doc))
              //                           .toList();
              //                       double subtotal =
              //                           calculateSubtotal(cartItems);
              //                       double deliveryFee =
              //                           calculateDeliveryFee(subtotal);
              //                       double total =
              //                           calculateTotal(subtotal, deliveryFee);
              //                       return Text(
              //                         '₹${total.toStringAsFixed(2)}',
              //                         style: Theme.of(context)
              //                             .textTheme
              //                             .headline5!
              //                             .copyWith(color: Colors.white),
              //                       );
              //                     } else {
              //                       return CircularProgressIndicator();
              //                     }
              //                   },
              //                 ),
              //               ],
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class CartProductCard extends StatelessWidget {
  final CartItem product;
  // final String uid;

  const CartProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          // Container(
          //   width: 100,
          //   height: 80,
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(12),
          //     image: DecorationImage(
          //       image: NetworkImage(
          //         product.postUrl.toString(),
          //       ),
          //     ),
          //   ),
          // ),
          Image.network(
            product.postUrl.toString(),
            width: 100,
            height: 80,
            fit: BoxFit.cover,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.itemName.toString(),
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "₹ " + product.price.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  print("quantity decrement");
                  product.quantity! == 1
                  ? FireStoreMethods()
                      .removeCartItem(product.buyerUid, product.postId)
                  : FireStoreMethods().decrementCartItemQuantity(
                      AuthMethods().getCurrentUserUid(),
                      product.postId,
                      product.quantity!,
                      product.price);
                },
                // : () {
                //     FireStoreMethods()
                //         .removeCartItem(product.buyerUid, product.postId);
                //   },
                icon: Icon(Icons.remove_circle, color: Colors.greenAccent.shade700,),
              ),
              Text(
                product.quantity!.toString(),
                style: Theme.of(context).textTheme.headline5,
              ),
              IconButton(
                onPressed: () {
                  print("quantity increment");
                  FireStoreMethods().incrementCartItemQuantity(
                      AuthMethods().getCurrentUserUid(),
                      product.postId,
                      product.quantity!,
                      product.price);
                },
                // : () {
                //     FireStoreMethods()
                //         .removeCartItem(product.buyerUid, product.postId);
                //   },
                icon: Icon(Icons.add_circle, color: Colors.greenAccent.shade700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
