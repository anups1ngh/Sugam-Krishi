import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sugam_krishi/screens/cameraScreen.dart';

import '../weather/constants.dart';

class UtilitiesPage extends StatefulWidget {
  const UtilitiesPage({Key? key}) : super(key: key);

  @override
  State<UtilitiesPage> createState() => _UtilitiesPageState();
}

class _UtilitiesPageState extends State<UtilitiesPage> {
  final Constants _constants = Constants();
  @override
  Widget build(BuildContext context) {
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
          "Utilities",
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
            setState(() {});
          },
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  //GOVERNMENT SCHEMES
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Government Schemes",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 200,
                      viewportFraction: 0.9,
                      autoPlay: true,
                    ),
                    items: [1, 2, 3, 4, 5].map((i) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                              margin: EdgeInsets.symmetric(horizontal: 5.0),
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white60,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                  child: Text(
                                'text $i',
                                style: TextStyle(fontSize: 16.0),
                              )));
                        },
                      );
                    }).toList(),
                  ),
                  //DIAGNOSTICS
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Diagnostics",
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          width: double.infinity,
                          padding:
                          EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          height: 200,
                          decoration: BoxDecoration(
                            // gradient: _constants.linearGradientGreen,
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/icons/plant.png",
                                        scale: 8,
                                      ),
                                      Text(
                                        "Take a Picture",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                        ),
                                      )
                                    ],
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: 40,
                                    color: Colors.black38,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/icons/plant_disease.png",
                                        scale: 8,
                                      ),
                                      Text(
                                        "Diagnose",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                        ),
                                      )
                                    ],
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: 40,
                                    color: Colors.black38,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/icons/cure.png",
                                        scale: 8,
                                      ),
                                      Text(
                                        "Get Cure",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 30),
                                child: FilledButton(
                                  // style: ButtonStyle(
                                  //   backgroundColor: MaterialStatePropertyAll<Color>(Colors.greenAccent.shade700),
                                  // ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => cameraScreen()),
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 14),
                                        child: FaIcon(
                                          FontAwesomeIcons.cameraRetro,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        "Take a Picture",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  //AI BOT
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Ask AI",
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            // gradient: _constants.linearGradientGreen,
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/icons/ai.png",
                                  scale: 7,
                                ),
                                Text(
                                  "Have queries or doubts ? \n Ask our state of the art AI",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 30),
                                  child: FilledButton(
                                    // style: ButtonStyle(
                                    //   backgroundColor: MaterialStatePropertyAll<Color>(Colors.greenAccent.shade700),
                                    // ),
                                    onPressed: () {

                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 14),
                                          child: FaIcon(
                                            FontAwesomeIcons.robot,
                                            size: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          "Ask AI",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
