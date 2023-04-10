import 'package:cart_stepper/cart_stepper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sugam_krishi/screens/postViewScreen.dart';
import 'package:intl/intl.dart';
import '../models/post.dart';

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

  String formatItemPrice(){
    return widget.snap['category'] == "Rent"
        ? "₹ " + widget.snap['price'].toString() + " per hour"
        : "₹ " + widget.snap['price'].toString() + " per kilogram";
  }
  @override
  void initState() {
    hasImage = widget.snap["postUrl"].toString() != "";
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {

      },
      child: Column(
        children: [
          Container(
            // height: hasImage ? 400 : 150,
            margin: EdgeInsets.only(top: 5, right: 5, left: 5, bottom: 0),
            // padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
              color: widget.snap["category"] == "Sell" ? Color(0xffC8E6C9) : Color(0xffFFFDE7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  hasImage ? Container(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.network(
                        widget.snap["postUrl"].toString(),
                      )
                  )
                      : Container(height: 0,),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 0),
                    child: Text(
                      widget.snap['itemName'].toString() + "  -  " + formatItemPrice(),
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  !widget.snap['description'].toString().isEmpty ? Padding(
                    padding: const EdgeInsets.only(
                        right: 6, left: 6, top: 0, bottom: 2),
                    child: Text(
                      widget.snap['description'].toString(),
                      style: GoogleFonts.poppins(
                          fontSize: 12, fontWeight: FontWeight.w400),
                      textAlign: TextAlign.left,
                    ),
                  ) : SizedBox(),
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
          Container(
            // height: hasImage ? 400 : 150,
            margin: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            width: double.infinity,
            // padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
              color: widget.snap["category"] == "Sell" ? Color(0xffC8E6C9) : Color(0xffFFFDE7),
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(12), bottomLeft: Radius.circular(12), topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: (widget.snap["category"] == "Sell" && startBuy) ? Align(
              alignment: Alignment.center,
              child: CartStepperInt(
                value: boughtValue,
                numberSize: MediaQuery.of(context).size.width * .037,
                size: 40,
                style: CartStepperTheme.of(context).copyWith(
                  activeForegroundColor: Colors.white,
                  // activeBackgroundColor: Color(0xff4CAF50),
                ),
                didChangeCount: (count) {
                  setState(() {
                    if(count == 0)
                      startBuy = false;
                    else
                      boughtValue = count;
                  });
                },
              ),
            ) : FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: widget.snap["category"] == "Sell" ? Color(0xff4CAF50) : Color(0xffFFB300),
              ),
              child: Text(
                widget.snap["category"] == "Sell" ? "Buy" : "Rent",
                style: GoogleFonts.poppins(fontSize: 20),
              ),
              onPressed: (){
                if(widget.snap["category"] == "Sell"){
                  setState(() {
                    startBuy = true;
                  });
                } else {

                }
              },
            ),
          ),
        ],
      ),
    );
  }
}