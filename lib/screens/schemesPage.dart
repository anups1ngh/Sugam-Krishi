import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'UtilitiesPage.dart';

class SchemesPage extends StatelessWidget {
  final Scheme scheme;
  const SchemesPage({Key? key, required this.scheme}) : super(key: key);

  _launchURL(Uri _uri) async{
    if (await canLaunchUrl(_uri)) {
      await launchUrl(
        _uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch $_uri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE0F2F1),
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   elevation: 1,
      //   // leading: const BackButton(
      //   //   color: Colors.black,
      //   // ),
      //   automaticallyImplyLeading: false,
      //   title: Text(
      //     "Utilities",
      //     textAlign: TextAlign.left,
      //     style: GoogleFonts.openSans(
      //       color: Colors.black,
      //     ),
      //   ),
      // ),
      body: SafeArea(
        child: Column(
          children: [
            Hero(
              tag: scheme.name,
              child: Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * .32,
                    // height: 250,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage("assets/scheme_back.jpg"),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 80,
                    color: Colors.black.withOpacity(0.2),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Text(
                        scheme.name,
                        textAlign: TextAlign.left,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * .58,
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.teal.shade100.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                Text(
                scheme.description,
                style: TextStyle(
                  fontSize: 17,
                  letterSpacing: 0.4,
                  height: 1.3,
                ),
                ),
                  SizedBox(
                    height: 45,
                    width: 250,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.greenAccent.shade700,

                      ),
                      onPressed: (){
                        _launchURL(Uri.parse(scheme.applyURL));
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Apply For this Scheme",
                            style: GoogleFonts.openSans(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            Icons.open_in_new_rounded,
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
    );
  }
}
