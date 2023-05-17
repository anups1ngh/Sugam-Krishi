import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sugam_krishi/providers/user_provider.dart';
import 'package:sugam_krishi/resources/firestore_methods.dart';
import 'package:sugam_krishi/utils/utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../constants.dart';
import '../../weather/locationSystem.dart';

class postPage extends StatefulWidget {
  final String userPhoto;
  final String userName;
  const postPage({Key? key, required this.userPhoto, required this.userName})
      : super(key: key);

  @override
  State<postPage> createState() => _postPageState();
}

class _postPageState extends State<postPage> {
  final TextEditingController _postController = TextEditingController();
  final Constants _constants = Constants();
  String _shareTo = "Anyone";
  bool isLoading = false;
  String res = "";
  String location = "";

  Uint8List? _image;
  bool _photoSelected = false;
  selectImage(ImageSource _source) async {
    Uint8List im = await pickImage(_source);
    // set state because we need to display the image we selected on the circle avatar
    setState(() {
      _image = im;
      _photoSelected = true;
    });
  }

  void showToastText(String text) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
// In post image function make it such that if we do not select an image then it will upload the post then also
  void postImage(String uid, String username, String profImage) async {
    // final ByteData bytes =
    //     await rootBundle.load('assets/login_illustration.jpg');
    // _img = bytes.buffer.asUint8List();
    LocationSystem.getPosition();
    setState(() {
      isLoading = true;
    });
    // start the loading
    try {
      // upload to storage and db
      if (_image != null) {
        res = await FireStoreMethods().uploadPost(
          _postController.text,
          _image!,
          uid,
          username,
          profImage,
          location,
        );
      } else {
        res = await FireStoreMethods().uploadPost(
          _postController.text,
          null,
          uid,
          username,
          profImage,
          location,
        );
      }

      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        showToastText(
          'Posted!',
        );
        clearImage();
        _postController.clear();
        Navigator.pop(context);
      } else {
        showToastText(res);
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showToastText(
        err.toString(),
      );
    }
  }

  void clearImage() {
    setState(() {
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 7),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: Color(0xff64FFDA).withOpacity(0.1),
                            backgroundImage: NetworkImage(
                              widget.userPhoto,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 0),
                              child: Text(
                                widget.userName,
                                style: GoogleFonts.poppins(
                                    fontSize: 18, fontWeight: FontWeight.w500),
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
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Colors.greenAccent.shade700),
                      ),
                      onPressed: () {
                        if (_postController.text.isNotEmpty) {
                          postImage(
                            userProvider.getUser.uid,
                            userProvider.getUser.username,
                            userProvider.getUser.photoUrl,
                          );
                        }
                      },
                      child: isLoading
                          ? SpinKitThreeBounce(
                              color: Colors.white,
                              size: 18,
                            )
                          : Text(
                              "Post",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ],
                ),
                TextField(
                  maxLines: 10,
                  controller: _postController,
                  autofocus: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white70,
                        width: 1.2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.green,
                        width: 1,
                      ),
                    ),
                    hintText: "Write something",
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                _photoSelected
                    ? Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: MemoryImage(
                              _image!,
                            ),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(
                            width: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        height: MediaQuery.of(context).size.height * 0.3,
                        // height: 300,
                        width: MediaQuery.of(context).size.width * 1,
                        child: Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            // Expanded(
                            //   child: Image.memory(
                            //     _image!,
                            //     fit: BoxFit.cover,
                            //   ),
                            // ),
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                icon: Icon(
                                  Icons.cancel_outlined,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _photoSelected = false;
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          FilledButton(
                            child: Row(
                              children: const [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 10),
                                  child: FaIcon(FontAwesomeIcons.image),
                                ),
                                Text("Add a Photo"),
                              ],
                            ),
                            onPressed: () {
                              selectImage(ImageSource.gallery);
                            },
                          ),
                          FilledButton(
                            child: Row(
                              children: const [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 10),
                                  child: FaIcon(FontAwesomeIcons.cameraRetro),
                                ),
                                Text("Take a Photo"),
                              ],
                            ),
                            onPressed: () {
                              selectImage(ImageSource.camera);
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
