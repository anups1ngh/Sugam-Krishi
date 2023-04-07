import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/post.dart';

class PostViewScreen extends StatefulWidget {
  final snap;
  final locationText;
  const PostViewScreen({Key? key, required this.snap, this.locationText}) : super(key: key);

  @override
  State<PostViewScreen> createState() => _PostViewScreenState();
}

class _PostViewScreenState extends State<PostViewScreen> {
  bool hasImage = true;

  @override
  void initState() {
    hasImage = widget.snap["postUrl"].toString() != "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Color(0xffE0F2F1),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent.withOpacity(0),
          elevation: 0,
          automaticallyImplyLeading: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: 60),
                Padding(
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
                            ),
                            child: Image.network(
                              widget.snap["postUrl"].toString(),
                            )
                        )
                            : Container(height: 0,),
                        SizedBox(height: 10,),
                        IconButton(
                          icon: Icon(
                            Icons.thumb_up_alt_outlined,
                            size: 26,
                          ),
                          onPressed: (){

                          },
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * .45,
                          margin: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade100.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          //COMMENTS VIEW
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance.collection('comments').snapshots(),
                            builder: (context,
                                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                              if (snapshot.connectionState == ConnectionState.done) {
                                if(snapshot.hasData){
                                  return Center(
                                    child: Text(
                                      "You have no saved password",
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                      ),
                                    ),
                                  );
                                }
                                else if(snapshot.data?.docs.length != null){
                                  return ListView.builder(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.data!.docs.length,
                                    itemBuilder: (context, index)
                                    => Text("Comment"),
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                  );
                                }
                              }
                              return Align(
                                alignment: Alignment.center,
                                child: Center(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                          "Loading Comments",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 16,
                                        )
                                      ),
                                      SpinKitThreeBounce(
                                      color: Colors.white,
                                      size: 22,
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Material(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          color: Colors.teal.shade100,
                          child: Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 0),
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Color(0xff64FFDA).withOpacity(0.1),
                                    backgroundImage: NetworkImage(
                                      widget.snap['profImage'].toString(),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    // focusNode: focusNode,
                                    // style: const TextStyle(color: Colors.white),
                                    // controller: _textEditingController,
                                    // onSubmitted: (value) async {
                                    //   _sendMessage();
                                    // },
                                    decoration: InputDecoration.collapsed(
                                      hintText: "Reply",
                                      hintStyle: TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                ),
                                IconButton(
                                    onPressed: () async {

                                    },
                                    icon: const Icon(
                                      Icons.send,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
