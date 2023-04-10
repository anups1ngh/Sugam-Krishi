import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sugam_krishi/screens/postViewScreen.dart';
import 'package:intl/intl.dart';
import '../models/post.dart';
import '../providers/user_provider.dart';
import '../resources/firestore_methods.dart';
import '../utils/like_animation.dart';
import '../utils/utils.dart';
import '../models/user.dart' as model;

class PostItem extends StatefulWidget {
  final snap;
  const PostItem({Key? key, required this.snap}) : super(key: key);

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  DateTime time = DateTime.now();
  bool hasImage = true;
  String publishedDifference = "";
  int commentLen = 0;
  String formatTimestamp(Timestamp timestamp) {
    var format = new DateFormat('d'); // <- use skeleton here
    return format.format(timestamp.toDate());
  }

  String getDateDifference(DateTime now, DateTime published) {
    Duration diff = now.difference(published);
    print(diff.inHours.toString());
    return diff.inHours.toString();
  }

  fetchCommentLen() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      commentLen = snap.docs.length;
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
    setState(() {});
  }

  Future<String> _fetchImageFromFirebase() async {
    return Future.delayed(Duration(seconds: 2), () => widget.snap["postUrl"]);
  }

  @override
  void initState() {
    hasImage = widget.snap["postUrl"].toString() != "";
    DateTime time = DateTime.now();
    // publishedDifference = getDateDifference(formatTimestamp(widget.snap["datePublished"]) , time);
    fetchCommentLen();
    super.initState();
    fetchCommentLen();
  }

  @override
  Widget build(BuildContext context) {
    final model.User user = Provider.of<UserProvider>(context).getUser;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostViewScreen(
              snap: widget.snap,
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
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                  child: Text(
                    widget.snap['description'].toString(),
                    style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.left,
                  ),
                ),
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
                                ));
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
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        LikeAnimation(
                          isAnimating: widget.snap['likes'].contains(user.uid),
                          smallLike: true,
                          child: IconButton(
                            icon: widget.snap['likes'].contains(user.uid)
                                ? Icon(FontAwesomeIcons.solidThumbsUp,
                                    size: 26, color: Colors.blueAccent)
                                : Icon(
                                    FontAwesomeIcons.thumbsUp,
                                    size: 26,
                                    //color: Colors.white60,
                                  ),
                            onPressed: () {
                              FireStoreMethods().likePost(
                                widget.snap['postId'].toString(),
                                user.uid,
                                widget.snap['likes'],
                              );
                            },
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
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(
                            FontAwesomeIcons.comment,
                            size: 26,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostViewScreen(
                                  snap: widget.snap,
                                ),
                              ),
                            );
                          },
                        ),
                        DefaultTextStyle(
                          style:
                              Theme.of(context).textTheme.subtitle2!.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.grey,
                                  ),
                          child: Text(
                            '${commentLen} replies',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
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
