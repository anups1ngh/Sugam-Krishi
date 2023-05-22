import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sugam_krishi/utils/orders_card.dart';

class OrderScreen extends StatefulWidget {
  final String currentUserUid;

  const OrderScreen({required this.currentUserUid});

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.currentUserUid)
            .collection('orders')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final orders = snapshot.data!.docs;
            if (orders != null && orders.isNotEmpty) {
              final pendingOrders = orders
                  .where((order) => order.data()['status'] == 'pending')
                  .toList();
              if (pendingOrders.isNotEmpty) {
                return ListView.builder(
                  itemCount: pendingOrders.length,
                  itemBuilder: (context, index) {
                    final order =
                        pendingOrders[index].data() as Map<String, dynamic>;
                    if (order != null) {
                      double cost = order['cost'].toDouble();
                      return OrderCard(
                        buyerName: order['buyerName'],
                        cost: cost,
                        itemName: order['itemName'],
                        orderID: order['orderId'],
                        postURL: order['postUrl'],
                        quantity: order['quantity'],
                        uid: order['sellerUid'],
                      );
                    } else {
                      return SizedBox();
                    }
                  },
                );
              } else {
                return Center(
                  child: Text('No pending orders'),
                );
              }
            } else {
              return Center(
                child: Text('No orders received yet'),
              );
            }
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error retrieving orders'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
