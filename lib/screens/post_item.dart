import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sugam_krishi/screens/postViewScreen.dart';

import '../models/post.dart';

class PostItem extends StatefulWidget {
  final snap;
  final String locationText;
  const PostItem({Key? key, required this.snap, required this.locationText}) : super(key: key);

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {

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
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PostViewScreen(
                snap: widget.snap,
                locationText: widget.locationText,
              ),
          ),
        );
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
          child: Hero(
            tag: widget.snap["uid"],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
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
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 0),
                          child: Text(
                            widget.locationText,
                            style: GoogleFonts.poppins(
                                fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ),
                        // DropdownButton(
                        //   elevation: 0,
                        //   items: [
                        //     DropdownMenuItem(child: Text("Anyone"), value: "Anyone",),
                        //     DropdownMenuItem(child: Text("Friends"), value: "Friends",),
                        //   ],
                        //   value: _shareTo,
                        //   onChanged: (value){
                        //     setState(() {
                        //       _shareTo = value!;
                        //     });
                        //   },
                        // ),
                      ],
                    ),
                  ],
                ),
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
                hasImage ? Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    // image: DecorationImage(
                    //   fit: BoxFit.,
                    //   image: NetworkImage(
                    //     widget.snap["postUrl"].toString(),
                    //   ),
                    // ),
                  ),
                    child: Image.network(
                      widget.snap["postUrl"].toString(),
                    )
                )
                    : Container(height: 0,),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(
                          Icons.thumb_up_alt_outlined,
                        size: 26,
                      ),
                      onPressed: (){

                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.comment_outlined,
                        size: 26,
                      ),
                      onPressed: (){

                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}