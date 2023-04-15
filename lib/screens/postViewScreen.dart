import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/comments.dart';
import '../models/user.dart' as model;
import '../models/post.dart';
import '../providers/user_provider.dart';
import '../resources/firestore_methods.dart';
import '../utils/like_animation.dart';
import '../utils/utils.dart';
import 'package:intl/intl.dart';

class PostViewScreen extends StatefulWidget {
  final snap;
  const PostViewScreen({Key? key, required this.snap}) : super(key: key);

  @override
  State<PostViewScreen> createState() => _PostViewScreenState();
}

class _PostViewScreenState extends State<PostViewScreen> {
  bool hasImage = true;
  int commentLen = 0;
  TextEditingController _commentController = TextEditingController();
  FocusNode focusNode = FocusNode();
  String location = "";

  Future<void> getLocationText() async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        LocationSystem.currPos.latitude, LocationSystem.currPos.longitude);

    setState(() {
      location = placemarks[0].subLocality.toString() +
          ", " +
          placemarks[0].locality.toString();
    });
  }

  fetchCommentLen() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      commentLen = snap.docs.length;
      print(snap.docs.length);
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
    setState(() {});
  }

  @override
  void initState() {
    fetchCommentLen();
    hasImage = widget.snap["postUrl"].toString() != "";
    _commentController = TextEditingController();
    focusNode = FocusNode();
    LocationSystem.getPosition();
    getLocationText();
    super.initState();
    fetchCommentLen();
  }

  @override
  Widget build(BuildContext context) {
    final model.User user = Provider.of<UserProvider>(context).getUser;
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
        body: ListView(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          children: [
            //POST IMAGE
            hasImage
                ? Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * .35,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(6)),
                      image: DecorationImage(
                        // image: AssetImage(
                        //   "assets/scheme_back.jpg",
                        // ),
                        image: NetworkImage(
                          widget.snap["postUrl"].toString(),
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    // child: Image.network(
                    //   widget.snap["postUrl"].toString(),
                    // )
                  )
                : Container(
                    height: 60,
                  ),

            //POST TEXT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                widget.snap['description'].toString(),
                // "Hello can anyone help me on this please can anyone help me on this please can anyone help me on this please ",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.15,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
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
                                widget.snap["location"].toString(),
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
                //BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          LikeAnimation(
                            isAnimating:
                                widget.snap['likes'].contains(user.uid),
                            smallLike: true,
                            child: SizedBox(
                              height: 36,
                              child: IconButton(
                                icon: widget.snap['likes'].contains(user.uid)
                                    ? Icon(FontAwesomeIcons.solidThumbsUp,
                                        size: 22, color: Colors.blueAccent)
                                    : Icon(
                                        FontAwesomeIcons.thumbsUp,
                                        size: 22,
                                        //color: Colors.white60,
                                      ),
                                onPressed: () {
                                  // setState(() {
                                  //   FireStoreMethods().likePost(
                                  //     widget.snap['postId'].toString(),
                                  //     user.uid,
                                  //     widget.snap['likes'],
                                  //   );
                                  // });
                                },
                              ),
                            ),
                          ),
                          DefaultTextStyle(
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2!
                                .copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.grey),
                            child: Text(
                              '${widget.snap['likes'].length} likes',
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 36,
                            child: IconButton(
                              icon: Icon(
                                FontAwesomeIcons.comment,
                                size: 22,
                              ),
                              onPressed: () {},
                            ),
                          ),
                          DefaultTextStyle(
                            style:
                                Theme.of(context).textTheme.subtitle2!.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.grey,
                                    ),
                            child: Text(
                              '$commentLen replies',
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            //COMMENTS FEED
            Container(
              height: hasImage
                  ? MediaQuery.of(context).size.height * .24
                  : MediaQuery.of(context).size.height * .51,
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
              decoration: BoxDecoration(
                color: Colors.teal.shade100.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(widget.snap['postId'].toString())
                    .collection('comments')
                    .orderBy('datePublished', descending: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Align(
                      alignment: Alignment.center,
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 22),
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade100.withOpacity(0.5),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Loading Comments",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                )),
                            SpinKitThreeBounce(
                              color: Colors.white,
                              size: 22,
                            )
                          ],
                        ),
                      ),
                    );
                  }
                  List<DocumentSnapshot> commentDocs = snapshot.data!.docs;
                  List<Comment> comments = [];
                  commentDocs.forEach((commentDoc) {
                    Comment comment = Comment.fromFirestore(commentDoc);
                    comments.add(comment);
                  });
                  return comments.length == 0
                      ? Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "No Comments yet",
                              style: GoogleFonts.montserrat(
                                fontStyle: FontStyle.italic,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        )
                      : Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            primary: false,
                            physics: BouncingScrollPhysics(),
                            itemCount: comments.length,
                            itemBuilder: (BuildContext context, int index) {
                              Comment comment = comments[index];
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          //PROFILE PIC
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 7),
                                            child: CircleAvatar(
                                              radius: 20,
                                              backgroundColor: Color(0xff64FFDA)
                                                  .withOpacity(0.1),
                                              backgroundImage: NetworkImage(
                                                comment.profilePic,
                                              ),
                                            ),
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              //USERNAME
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 5,
                                                        vertical: 0),
                                                    child: Text(
                                                      comment.name,
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                      textAlign: TextAlign.left,
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
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 5,
                                                        vertical: 0),
                                                    child: Text(
                                                      comment.location,
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black54,
                                                      ),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              //COMMENT
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5,
                                                        vertical: 0),
                                                child: Text(
                                                  comment.text,
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                  textAlign: TextAlign.left,
                                                  softWrap: true,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  //DATE PUBLISHED
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 0),
                                    child: Text(
                                      DateFormat.yMMMd().format(
                                        comment.datePublished,
                                      ),
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                },
              ),
            ),

            //COMMENT TEXTFIELD
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: Material(
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
                            controller: _commentController,
                            decoration: InputDecoration.collapsed(
                              hintText: "Reply",
                              hintStyle: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            print("pressed");
                            FireStoreMethods().postComment(
                              widget.snap['postId'].toString(),
                              _commentController.text,
                              user.uid,
                              user.username,
                              user.photoUrl,
                              location,
                            );
                            _commentController.clear();
                            focusNode.unfocus();
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
