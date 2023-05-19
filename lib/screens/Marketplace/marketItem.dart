import 'dart:io';

import 'package:cart_stepper/cart_stepper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sugam_krishi/screens/Community/postViewScreen.dart';
import 'package:intl/intl.dart';
import '../../models/post.dart';
import 'package:http/http.dart' as http;

class MarketItem extends StatefulWidget {
  final snap;
  const MarketItem({Key? key, required this.snap}) : super(key: key);

  @override
  State<MarketItem> createState() => _MarketItemState();
}

class _MarketItemState extends State<MarketItem> {
  bool hasImage = true;
  int boughtValue = 1;
  bool startBuy = false;

  String formatItemPrice() {
    return widget.snap['category'] == "Rent"
        ? "₹ " + widget.snap['price'].toString() + " per hour"
        : "₹ " + widget.snap['price'].toString() + " per kilogram";
  }

  @override
  void initState() {
    hasImage = widget.snap["postUrl"].toString() != "";

    super.initState();
  }

  _callNumber(String phoneNumber) async {
    String number = phoneNumber;
    await FlutterPhoneDirectCaller.callNumber(number);
  }

  Future<String> _fetchImageFromFirebase() async {
    return Future.delayed(Duration(seconds: 0), () => widget.snap["postUrl"]);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Container(
            // height: hasImage ? 400 : 150,
            margin: EdgeInsets.only(top: 5, right: 5, left: 5, bottom: 0),
            // padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
              color: widget.snap["category"] == "Sell"
                  ? Color(0xffC8E6C9)
                  : Color(0xffFFFDE7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  hasImage
                      ? FutureBuilder(
                          future:
                              _fetchImageFromFirebase(), // replace with your own function to fetch the image
                          builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.hasData) {
                              return Container(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Image.network(
                                  snapshot.data!,
                                ),
                              );
                            } else {
                              return AspectRatio(
                                aspectRatio: 1,
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        )
                      : Container(
                          height: 0,
                        ),

                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 0),
                        child: Text(
                          widget.snap['itemName'].toString() +
                              "  -  " +
                              formatItemPrice(),
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      (widget.snap['category'] == "Sell")
                          ? Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${widget.snap['quantity'].toString()} kg',
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                                textAlign: TextAlign.right,
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                  !widget.snap['description'].toString().isEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(
                              right: 6, left: 6, top: 0, bottom: 2),
                          child: Text(
                            widget.snap['description'].toString(),
                            style: GoogleFonts.poppins(
                                fontSize: 14, fontWeight: FontWeight.w400),
                            textAlign: TextAlign.left,
                          ),
                        )
                      : SizedBox(),
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
                            widget.snap['profImage'].toString(),
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
                              widget.snap['username'].toString(),
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
                                  widget.snap['location'].toString(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
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
                                  DateFormat.yMMMd().format(
                                    widget.snap['datePublished'].toDate(),
                                  ),
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                  // SizedBox(height: 10,),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.start,
                  //   children: [
                  //     IconButton(
                  //       icon: Icon(
                  //         Icons.thumb_up_alt_outlined,
                  //         size: 26,
                  //       ),
                  //       onPressed: (){
                  //
                  //       },
                  //     ),
                  //     IconButton(
                  //       icon: Icon(
                  //         Icons.comment_outlined,
                  //         size: 26,
                  //       ),
                  //       onPressed: (){
                  //
                  //       },
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: FilledButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        widget.snap['category'] == "Sell"
                            ? Colors.green
                            : Color.fromARGB(255, 239, 198, 80),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          child: FaIcon(FontAwesomeIcons.cartShopping),
                        ),
                        widget.snap['category'] == "Sell"
                            ? const Text("Buy")
                            : const Text("Rent"),
                      ],
                    ),
                    onPressed: () {
                      _callNumber(widget.snap['contact'].toString());
                    },
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: FilledButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        widget.snap['category'] == "Sell"
                            ? Colors.green
                            : Color.fromARGB(255, 239, 198, 80),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          child: FaIcon(FontAwesomeIcons.shareFromSquare),
                        ),
                        Text("Share"),
                      ],
                    ),
                    onPressed: () async {
                      final urlImg = widget.snap['postUrl'].toString();
                      final url = Uri.parse(urlImg);
                      final response = await http.get(url);
                      final bytes = response.bodyBytes;

                      final temp = await getTemporaryDirectory();
                      final path = '${temp.path}/image.png';
                      final file = File(path).writeAsBytesSync(bytes);

                      await Share.shareFiles([path],
                          text: widget.snap['category'] == "Sell"
                              ? '${widget.snap['itemName'].toString()}\n\n${widget.snap['quantity'].toString()}kg of ${widget.snap['itemName'].toString()} is available for sell at ${widget.snap['location'].toString()} for ₹${widget.snap['price'].toString()}.\nSeller: ${widget.snap['username'].toString()}\nSeller contact : ${widget.snap['contact'].toString()}\n\n Checkout Sugam Krishi App for more details.'
                              : '${widget.snap['itemName'].toString()}\n\nIt is available for rent at ${widget.snap['location'].toString()} for ₹${widget.snap['price'].toString()}.\nSeller: ${widget.snap['username'].toString()}\nSeller contact : ${widget.snap['contact'].toString()}\n\n Checkout Sugam Krishi App for more details.');
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
