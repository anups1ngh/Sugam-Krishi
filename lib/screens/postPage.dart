import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';

class postPage extends StatefulWidget {
  const postPage({Key? key}) : super(key: key);

  @override
  State<postPage> createState() => _postPageState();
}

class _postPageState extends State<postPage> {

  final Widget _avatar = Icon(Icons.person_outline_rounded);
  final String _name = "Name";
  final TextEditingController _postController = TextEditingController();
  final Constants _constants = Constants();
  @override
  Widget build(BuildContext context) {
    String _shareTo = "Anyone";
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        // reverse: true,
        child: Container(
          // height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            // gradient: _constants.linearGradientTeal,
            color: Color(0xffE0F2F1),
            boxShadow: [
              // BoxShadow(
              //   color: _constants.primaryColor.withOpacity(.2),
              //   spreadRadius: 5,
              //   blurRadius: 7,
              //   offset: const Offset(0, 3),
              // ),
            ],
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18), topRight: Radius.circular(18)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
                          child: CircleAvatar(
                            radius: 24,
                            child: _avatar,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _name,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
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
                    FilledButton(
                      onPressed: (){

                      },
                      child: Text("Post"),
                    ),
                  ],
                ),
                TextField(
                  maxLines: 10,
                  controller: _postController,
                  autofocus: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white70,
                        width: 1.2,
                      ),
                    ),
                    hintText: "Write something",
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FilledButton(
                      child: Row(
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                            child: FaIcon(FontAwesomeIcons.image),
                          ),
                          Text("Add a Photo"),
                        ],
                      ),
                      onPressed: (){

                      },
                    ),
                    FilledButton(
                      child: Row(
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                            child: FaIcon(FontAwesomeIcons.cameraRetro),
                          ),
                          Text("Take a Photo"),
                        ],
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
