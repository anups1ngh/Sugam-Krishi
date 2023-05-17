import 'package:animated_switcher_plus/animated_switcher_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sugam_krishi/providers/user_provider.dart';
import 'package:sugam_krishi/screens/Marketplace/PostItemPage.dart';
import 'package:sugam_krishi/models/user.dart' as model;
import 'package:sugam_krishi/screens/Marketplace/marketItem.dart';

import '../../providers/value_providers.dart';

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

  List<String> tabs = [
    "Sell",
    "Rent",
  ];
  int current = 0;

  double changePositionedOfLine() {
    switch (current) {
      case 0:
        return 0;
      case 1:
        return 50;
      default:
        return 0;
    }
  }

  double changeContainerWidth() {
    switch (current) {
      case 0:
        return 40;
      case 1:
        return 50;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    model.User user = Provider.of<UserProvider>(context).getUser;
    var size = MediaQuery.of(context).size;
    showFAB = Provider.of<ValueProviders>(context).shouldShowMarketplaceFAB;
    return Scaffold(
      backgroundColor: Color(0xffE0F2F1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Text(
          "Marketplace",
          textAlign: TextAlign.left,
          style: GoogleFonts.openSans(
            color: Colors.black,
          ),
        ),
      ),
      body: RefreshIndicator(
        edgeOffset: 40,
        strokeWidth: 2.5,
        color: Color(0xff0ba99b),
        onRefresh: () async {
          await Future.delayed(Duration(milliseconds: 800));
          setState(() {});
        },
        child: SafeArea(
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  //alignment: Alignment.center,
                  margin: const EdgeInsets.only(top: 15),
                  width: size.width,
                  height: size.height * 0.05,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SizedBox(
                          width: size.width,
                          height: size.height * 0.04,
                          child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemCount: tabs.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                      left: index == 0 ? 10 : 23, top: 7),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        current = index;
                                      });
                                    },
                                    child: Text(
                                      tabs[index],
                                      style: GoogleFonts.ubuntu(
                                        fontSize: current == index ? 20 : 18,
                                        fontWeight: current == index
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ),
                      AnimatedPositioned(
                        curve: Curves.fastLinearToSlowEaseIn,
                        bottom: 0,
                        left: changePositionedOfLine(),
                        duration: const Duration(milliseconds: 500),
                        child: AnimatedContainer(
                          margin: const EdgeInsets.only(left: 10),
                          width: changeContainerWidth(),
                          height: size.height * 0.006,
                          decoration: BoxDecoration(
                            color: Colors.teal,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.fastLinearToSlowEaseIn,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                "${tabs[current]}" == "Sell"
                    ? Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("marketplace")
                              .where("category", isEqualTo: "Sell")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              print(
                                  'Sell count : ${snapshot.data!.docs.length}');
                              return ListView.builder(
                                padding: EdgeInsets.only(bottom: 100),
                                controller: scrollController,
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  return MarketItem(
                                    snap: snapshot.data!.docs[index].data(),
                                  );
                                },
                              );
                            } else {
                              return Center(
                                child: SpinKitThreeBounce(
                                  color: Colors.white,
                                  size: 22,
                                ),
                              );
                            }
                          },
                        ),
                      )
                    : Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("marketplace")
                              .where("category", isEqualTo: "Rent")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              print(
                                  'Sell count : ${snapshot.data!.docs.length}');
                              return ListView.builder(
                                padding: EdgeInsets.only(bottom: 100),
                                controller: scrollController,
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  return MarketItem(
                                    snap: snapshot.data!.docs[index].data(),
                                  );
                                },
                              );
                            } else {
                              return Center(
                                child: SpinKitThreeBounce(
                                  color: Colors.white,
                                  size: 22,
                                ),
                              );
                            }
                          },
                        ),
                      )
                // : const Center(
                //     child: SpinKitFadingCircle(
                //       color: Colors.green,
                //       size: 50.0,
                //     ),
                //   ),
              ],
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
    );
  }
}
