import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderCard extends StatelessWidget {
  final String buyerName;
  final String buyerContact;
  final String buyerAddress;
  final double cost;
  final String itemName;
  final String orderID;
  final String postURL;
  final int quantity;
  final String unit;
  final String uid;

  OrderCard({
    required this.buyerName,
    required this.cost,
    required this.itemName,
    required this.orderID,
    required this.postURL,
    required this.quantity,
    required this.unit,
    required this.uid,
    required this.buyerContact,
    required this.buyerAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white60,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 5, vertical: 7),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xff64FFDA).withOpacity(0.1),
                  backgroundImage: NetworkImage(
                    postURL,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 0),
                    child: Text(
                      itemName,
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 3, vertical: 0),
                        child: Text(
                          "$quantity $unit",
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black54,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 3, vertical: 0),
                        child: Text(
                          "Total: ₹ $cost",
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
            child: Text(
              "Order ID: $orderID",
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.left,
            ),
          ),
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
            child: Text(
              "Buyer: $buyerName",
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.left,
            ),
          ),
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
            child: Text(
              "Buyer contact: $buyerContact",
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.left,
            ),
          ),
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
            child: Text(
              "Buyer address: $buyerAddress",
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.left,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Align(
              alignment: Alignment.center,
              child: FilledButton(
                onPressed: (){
                  updateOrderStatus();
                },
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.greenAccent.shade700,
                    fixedSize: Size(100, 42),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)
                ),
                child: Text(
                  "Done",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showToastText(String text) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void updateOrderStatus() {
    // Update the order status in Firebase
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('orders')
        .doc(orderID)
        .update({'status': 'done'})
        .then((_) => showToastText('Order status updated successfully'))
        .catchError(
            (error) => showToastText('Error updating order status: $error'));
  }
}
