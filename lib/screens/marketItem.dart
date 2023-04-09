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
      child: Container(
        // height: hasImage ? 400 : 150,
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        // padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white60,
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
                  widget.snap['description'].toString(),
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.left,
                ),
              ),
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
    );
  }
}