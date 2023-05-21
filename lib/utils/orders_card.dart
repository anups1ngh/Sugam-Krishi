import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OrderCard extends StatelessWidget {
  final String buyerName;
  final double cost;
  final String itemName;
  final String orderID;
  final String postURL;
  final int quantity;
  final String uid;

  OrderCard({
    required this.buyerName,
    required this.cost,
    required this.itemName,
    required this.orderID,
    required this.postURL,
    required this.quantity,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(top: 10, right: 12, bottom: 10),
                  child: CircleAvatar(
                    radius: 32.0,
                    backgroundImage: NetworkImage(postURL),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buyer Name: $buyerName',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.0),
                    Text('Cost: $cost', style: TextStyle(fontSize: 16.0)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Text('Item Name: $itemName', style: TextStyle(fontSize: 16.0)),
            SizedBox(height: 8.0),
            Text('Quantity: $quantity', style: TextStyle(fontSize: 16.0)),
            SizedBox(height: 8.0),
            Text('Order ID: $orderID', style: TextStyle(fontSize: 16.0)),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => updateOrderStatus(),
              child: Text('Done'),
            ),
          ],
        ),
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
