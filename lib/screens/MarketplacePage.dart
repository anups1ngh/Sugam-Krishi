import 'package:animated_switcher_plus/animated_switcher_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sugam_krishi/providers/user_provider.dart';
import 'package:sugam_krishi/screens/PostItemPage.dart';
import 'package:sugam_krishi/models/user.dart' as model;
import 'package:sugam_krishi/screens/marketItem.dart';

import '../providers/value_providers.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({Key? key}) : super(key: key);

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  bool showFAB = true;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    model.User user = Provider.of<UserProvider>(context).getUser;
    showFAB = Provider.of<ValueProviders>(context).shouldShowMarketplaceFAB;
    return Scaffold(
      backgroundColor: Color(0xffE0F2F1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        // leading: const BackButton(
        //   color: Colors.black,
        // ),
        automaticallyImplyLeading: false,
        title: Text(
          "Marketplace",
          textAlign: TextAlign.left,
          style: GoogleFonts.openSans(
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          edgeOffset: 40,
          strokeWidth: 2.5,
          color: Color(0xff0ba99b),
          onRefresh: () async {
            await Future.delayed(Duration(milliseconds: 800));
            setState(() {

            });
          },
          child: NotificationListener<UserScrollNotification>(
            onNotification: (notification){
            if(notification.direction == ScrollDirection.forward){
              // Provider.of<ValueProviders>(context, listen: false).toggleShowMarketplaceFAB();
            } else if(notification.direction == ScrollDirection.reverse){
              // Provider.of<ValueProviders>(context, listen: false).toggleShowMarketplaceFAB();
            }
            return true;
            },
            child: SingleChildScrollView(
              child: //POSTS FEED
              Padding(
                padding: const EdgeInsets.all(10),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('marketplace').snapshots(),
                  builder: (context,
                      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: SpinKitThreeBounce(
                          color: Colors.white,
                          size: 22,
                        ),
                      );
                    }
                    print(snapshot.data!.docs.length);
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) => MarketItem(
                        snap: snapshot.data!.docs[index].data(),
                      ),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: FloatingActionButton.extended(
          elevation: 1,
          // backgroundColor: Color(0xff00897B),
          backgroundColor: Colors.greenAccent.shade700,
          icon: Icon(
            Icons.shopping_cart,
            size: 20,
            color: Colors.white,
          ),
          label: Text(
            "Sell/Rent",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          onPressed: () {
            showModalBottomSheet<void>(
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
              ),
              context: context,
              builder: (BuildContext context) {
                return postItemPage(
                  userName: user.username,
                  userPhoto: user.photoUrl,
                );
              },
            );
          },
        ),
      ),
      // floatingActionButton: AnimatedSwitcherTranslation.bottom(
      //   duration: const Duration(milliseconds: 300),
      //   child: showFAB ? Padding(
      //     padding: const EdgeInsets.symmetric(horizontal: 3),
      //     child: FloatingActionButton.extended(
      //       elevation: 1,
      //       // backgroundColor: Color(0xff00897B),
      //       backgroundColor: Colors.greenAccent.shade700,
      //       icon: Icon(
      //         Icons.shopping_cart,
      //         size: 20,
      //         color: Colors.white,
      //       ),
      //       label: Text(
      //         "Sell/Rent",
      //         style: TextStyle(
      //           fontSize: 15,
      //           fontWeight: FontWeight.w700,
      //           color: Colors.white,
      //         ),
      //       ),
      //       onPressed: () {
      //         showModalBottomSheet<void>(
      //           isScrollControlled: true,
      //           shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.vertical(
      //               top: Radius.circular(18),
      //             ),
      //           ),
      //           context: context,
      //           builder: (BuildContext context) {
      //             return postItemPage(
      //               userName: user.username,
      //               userPhoto: user.photoUrl,
      //             );
      //           },
      //         );
      //       },
      //     ),
      //   ) : null,
      // ),
    );
  }
}
