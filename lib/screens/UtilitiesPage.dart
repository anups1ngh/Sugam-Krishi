import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sugam_krishi/screens/AI-Bot/chatScreen.dart';
import 'package:sugam_krishi/screens/cameraScreen.dart';
import 'package:sugam_krishi/screens/schemesPage.dart';
import 'package:sugam_krishi/screens/ytPlayerScreen.dart';
import 'package:youtube_api/youtube_api.dart';
import '../keys.dart';
import 'package:http/http.dart' as http;

List<int> schemesList = [1, 2, 3, 4, 5];
List<int> videosList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0];
const String schemesURL = "https://script.google.com/macros/s/AKfycbx1lF_t19M15c2gj6jQGXT3HAT4lHeSfAEgUqwkzXoe_bh9l8GHEQzjKtwuLipq1_inxQ/exec";
class Scheme{
  final String name;
  final String description;
  final String applyURL;
  final String imageURL;
  Scheme({required this.name, required this.description, required this.applyURL, required this.imageURL,});

  factory Scheme.fromJson(Map<String, dynamic> json){
    return Scheme(
      name: json["SchemeName"],
      description: json["Details"],
      applyURL: "",
      imageURL: "",
    );
  }
}
class UtilitiesPage extends StatefulWidget {
  const UtilitiesPage({Key? key}) : super(key: key);

  @override
  State<UtilitiesPage> createState() => _UtilitiesPageState();
}

class _UtilitiesPageState extends State<UtilitiesPage> {
  bool _videosLoaded = false;
  bool _schemesLoaded = false;

  YoutubeAPI youtube = YoutubeAPI(YT_API_KEY, maxResults: 5);
  List<YouTubeVideo> videoResult = [];
  List<Scheme> schemes = [];

  Future<void> callYTAPI(String query) async {
    videoResult = await youtube.search(
      query,
      order: 'relevance',
      videoDuration: 'any',
    );
    videoResult = await youtube.nextPage();
    setState(() {});
  }
  Future<void> callSchemesAPI() async{
    var res = await http.get(Uri.parse(schemesURL));
    List<dynamic> schemesMap = json.decode(res.body);
    schemesMap.forEach((scheme) {
      schemes.add(
          new Scheme.fromJson(scheme)
      );
    },
    );
    setState(() {

    });
  }
  @override
  void initState() {
    callYTAPI("Modern farming techniques").then((value) => _videosLoaded = true);
    callSchemesAPI().then((value) => _schemesLoaded = true);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
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
                      autoPlayInterval: const Duration(seconds: 5),
                    ),
                    items: _schemesLoaded
                        ? schemes.map<Widget>((scheme) {
                      return Builder(
                        builder: (BuildContext context) {
                          return schemeListItem(context, scheme);
                        },
                      );
                    }).toList()
                        : schemesList.map((i) {
                      return Builder(
                        builder: (BuildContext context) {
                          return schemeShimmer();
                        },
                      );
                    }).toList(),
                  ),
                  //LEARN
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Learn",
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
                      height: 300,
                      viewportFraction: 0.9,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 5),
                    ),
                    items: _videosLoaded
                        ? videoResult.map<Widget>((video) {
                      return Builder(
                        builder: (BuildContext context){
                          return listItem(video, context);
                        },
                      );
                    }).toList()
                        : videosList.map((i) {
                      return Builder(
                        builder: (BuildContext context) {
                          return ytShimmer();
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
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => chatScreen()),
                                      );
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

Shimmer schemeShimmer(){
  return Shimmer.fromColors(
    baseColor: Colors.grey[200]!,
    highlightColor: Colors.grey[50]!,
    child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5.0),
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
    ),
  );

}
Shimmer ytShimmer(){
  return Shimmer.fromColors(
    baseColor: Colors.grey[200]!,
    highlightColor: Colors.grey[50]!,
    child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5.0),
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
    ),
  );
}

Widget schemeListItem(BuildContext context, Scheme scheme){
  return GestureDetector(
    onTap: (){
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                SchemesPage(
              scheme: scheme,
            ),
        ),
      );
    },
    child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5.0),
        padding: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Hero(
        tag: scheme.name,
        child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                    image: AssetImage("assets/scheme_back.jpg"),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Container(
                width: double.infinity,
                // height: 80,
                color: Colors.black.withOpacity(0.2),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    scheme.name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
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

Widget listItem(YouTubeVideo video, BuildContext context) {
  return GestureDetector(
    onTap: (){
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ytPlayerScreen(videoID: video.id!)),
      );
    },
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white60,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                video.thumbnail.high.url ?? '',
                width: MediaQuery.of(context).size.width * .7,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(
                video.title,
                textAlign: TextAlign.center,
                softWrap: true,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                video.channelTitle,
                softWrap: true,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )
        ],
      ),
    ),
  );
}