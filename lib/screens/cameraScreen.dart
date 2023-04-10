import 'dart:io';
import 'dart:typed_data';
import 'package:better_open_file/better_open_file.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/pigeon.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sugam_krishi/screens/diagnosisBottomSheet.dart';
import 'package:sugam_krishi/screens/diagnosisPage.dart';
import 'package:sugam_krishi/screens/postPage.dart';
import 'package:tflite/tflite.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import 'package:url_launcher/url_launcher.dart';
import '../providers/user_provider.dart';
import '../utils/utils.dart';
import 'AI-Bot/chatScreen.dart';
import 'package:sugam_krishi/models/user.dart' as model;

class cameraScreen extends StatefulWidget {
  const cameraScreen({Key? key}) : super(key: key);

  @override
  State<cameraScreen> createState() => _cameraScreenState();
}

class _cameraScreenState extends State<cameraScreen> {
  File? _image;
  List? _output;
  bool _photoSelected = false;
  final imagepicker = ImagePicker();
  String diseaseName = "";
  Uint8List? bytes;

  _launchURL(Uri _uri) async {
    if (await canLaunchUrl(_uri)) {
      await launchUrl(
        _uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch $_uri';
    }
  }

  selectImage(ImageSource _source) async {
    var image = await imagepicker.getImage(source: _source);
    if (image != null) {
      _image = File(image.path);

      setState(() {
        _photoSelected = true;
        bytes = _image!.readAsBytesSync();
      });
      run_ML_Model(_image!);
    }
  }

  Future<void> initTensorflow(String modelPath, String labelPath) async {
    String? res = await Tflite.loadModel(
        model: modelPath,
        labels: labelPath,
        numThreads: 1, // defaults to 1
        isAsset:
            true, // defaults to true, set to false to load resources outside assets
        useGpuDelegate:
            false // defaults to false, set to true to use GPU delegate
        );
    print(res);
  }

  run_ML_Model(File image) async {
    try {
      print(image.path);
      var recognitions = await Tflite.runModelOnImage(
          path: image.path, // required
          imageMean: 0.0, // defaults to 117.0
          imageStd: 255.0, // defaults to 1.0
          numResults: 5, // defaults to 5
          threshold: 0.1, // defaults to 0.1
          asynch: true // defaults to true
          );
      if (recognitions == null)
        throw "Null response";
      else if (recognitions.isEmpty)
        throw "Empty response";
      else {
        setState(() {
          _output = recognitions;
          diseaseName =
              formatDiseaseName((_output?[0]['label']).toString().substring(2));
          print(_output);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    selectImage(ImageSource.camera);
    initTensorflow("assets/model_unquant.tflite", "assets/labels.txt")
        .then((value) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() async {
    await Tflite.close();
    super.dispose();
  }

  String formatDiseaseName(String name) {
    return name
        .replaceAll("_", " ")
        .split(" ")
        .map((word) {
          if (word.isEmpty)
            return word;
          else
            return word[0].toUpperCase() + word.substring(1);
        })
        .toList()
        .join(" ");
  }

  String formatConfidence(double conf) {
    double perc = conf * 100;
    perc = double.parse(perc.toStringAsFixed(2));
    return "\n$perc % confidence";
  }

  @override
  Widget build(BuildContext context) {
    model.User user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      backgroundColor: Color(0xffE0F2F1),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: const BackButton(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: true,
        title: Text(
          "Diagnosis",
          textAlign: TextAlign.left,
          style: GoogleFonts.openSans(
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: ClipRRect(
                  child: _photoSelected
                      ? Image.file(_image!)
                      : SizedBox(
                          height: 60,
                        ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              // _output != null
              //     ? (_output[0]['label']).toString().substring(2)
              //     : "Sorry, our model couldn't detect. Ask in the community",
              // style: GoogleFonts.poppins(
              //   fontSize: 20,
              //   fontWeight: FontWeight.w500,
              // ),
              GestureDetector(
                onTap: () {
                  _launchURL(Uri.parse("https://www.google.com/search?q=" +
                      diseaseName.replaceAll(" ", "+")));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.teal.shade400,
                      width: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: _output != null
                          ? diseaseName
                          : "Sorry, our model couldn't detect. Ask in the community",
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(
                          text: _output != null
                              ? formatConfidence((_output?[0]['confidence']))
                              : "",
                          style: GoogleFonts.poppins(
                            color: Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 100,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.greenAccent.shade700,
                    ),
                    child: Row(
                      children: const [
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          child: FaIcon(FontAwesomeIcons.shareFromSquare),
                        ),
                        Text("Ask in the community"),
                      ],
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
                          return diagnosisSheet(
                              userName: user.username,
                              userPhoto: user.photoUrl,
                              diseaseName: diseaseName,
                              image: bytes);
                        },
                      );
                    },
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.greenAccent.shade700,
                    ),
                    child: Row(
                      children: const [
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          child: FaIcon(FontAwesomeIcons.comments),
                        ),
                        Text("Ask AI"),
                      ],
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => chatScreen(
                                  initialQuery: diseaseName,
                                )),
                      );
                    },
                  ),
                ],
              ),
              // _output != null
              //     ? Text(
              //     (_output[0]['label']).toString().substring(2),
              //     style: GoogleFonts.roboto(fontSize: 18))
              //     : Text(''),
              // _output != null
              //     ? Text(
              //     'Confidence: ' +
              //         (_output[0]['confidence']).toString(),
              //     style: GoogleFonts.roboto(fontSize: 18))
              //     : Text('')
            ],
          ),
        ),
      ),
    );
  }
}
