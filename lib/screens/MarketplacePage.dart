import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MarketplacePage extends StatelessWidget {
  const MarketplacePage({Key? key}) : super(key: key);

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
          "Marketplace",
          textAlign: TextAlign.left,
          style: GoogleFonts.openSans(
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(

          ),
        ),
      ),
    );
  }
}
