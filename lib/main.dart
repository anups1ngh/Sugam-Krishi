import 'dart:io';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sugam_krishi/providers/user_provider.dart';
import 'package:sugam_krishi/providers/value_providers.dart';
import 'package:sugam_krishi/screens/HomePage.dart';
import 'package:sugam_krishi/screens/loginPage.dart';
import 'package:sugam_krishi/screens/signupPage.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:sugam_krishi/onboard/onboard.dart';


List<CameraDescription> cameras = [];

int? isviewed;
Future<void> main() async {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
    } on CameraException catch (e) {
    print('Error in fetching the cameras: $e');
  }

  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  isviewed = prefs.getInt('onBoard');
  await Firebase.initializeApp();
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ValueProviders()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sugam Krishi',
        theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          primarySwatch: Colors.green,
        ),
        home: isviewed != 0 ? OnBoard() : StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                return HomePage();
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                color: Colors.teal,
              ));
            }
            return const LoginPage();
          },
        ),
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
