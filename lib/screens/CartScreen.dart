import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
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

  void openPaymentPortal(int total) async {
    print("Making payment");
    var options = {
      'key': 'rzp_test_l6N7mjNyhTQJUs',
      'amount': total,
      'name': 'jhon',
      'currency': 'INR',
      'description': 'Payment',
      'prefill': {'contact': '9999999999', 'email': 'jhon@razorpay.com'},
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
        msg: "Payment Failed😢: ${response.code} - ${response.message}",
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
    // model.User user = Provider.of<UserProvider>(context).getUser;
    // String userUid = user.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Cart",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        child: Container(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.white),
                onPressed: () {
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
                      openPaymentPortal(amount);
                    }
                  });
                },
                child: Text(
                  "Checkout",
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        if (subtotal < 500) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9.0, vertical: 20),
                            child: Column(
                              children: [
                                Text(
                                  "Add ₹500 worth products for Free Delivery!",
                                  style: Theme.of(context).textTheme.headline6,
                                  softWrap: true,
                                ),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const MarketplacePage()),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.black,
                                      shape: RoundedRectangleBorder(),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      "Add more items",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .copyWith(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return SizedBox();
                        }
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  ),
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
                          return CircularProgressIndicator();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Divider(
                  thickness: 2,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40.0, vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Subtotal",
                            style: Theme.of(context).textTheme.headline5,
                          ),
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
                                  '₹${subtotal.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.headline5,
                                );
                              } else {
                                return CircularProgressIndicator();
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Delivery Fee",
                            style: Theme.of(context).textTheme.headline5,
                          ),
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
                                double deliveryFee =
                                    calculateDeliveryFee(subtotal);
                                return Text(
                                  '₹${deliveryFee.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.headline5,
                                );
                              } else {
                                return CircularProgressIndicator();
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(50),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.all(5),
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.black,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5!
                                  .copyWith(color: Colors.white),
                            ),
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
                                  double subtotal =
                                      calculateSubtotal(cartItems);
                                  double deliveryFee =
                                      calculateDeliveryFee(subtotal);
                                  double total =
                                      calculateTotal(subtotal, deliveryFee);
                                  return Text(
                                    '₹${total.toStringAsFixed(2)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline5!
                                        .copyWith(color: Colors.white),
                                  );
                                } else {
                                  return CircularProgressIndicator();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
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
                  style: Theme.of(context).textTheme.headline5,
                ),
                Text(
                  "₹" + product.price.toString(),
                  style: Theme.of(context).textTheme.headline6,
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
                  FireStoreMethods().decrementCartItemQuantity(
                      AuthMethods().getCurrentUserUid(),
                      product.postId,
                      product.quantity!,
                      product.price);
                },
                // : () {
                //     FireStoreMethods()
                //         .removeCartItem(product.buyerUid, product.postId);
                //   },
                icon: Icon(Icons.remove_circle),
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
                icon: Icon(Icons.add_circle),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
