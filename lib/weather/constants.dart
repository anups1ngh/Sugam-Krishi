import 'package:flutter/material.dart';

class Constants {
  final primaryColor = const Color(0xff00796B);
  final secondaryColor = const Color(0xff80CBC4);
  final tertiaryColor = const Color(0xff205cf1);
  final blackColor = const Color(0xff1a1d26);

  final greyColor = const Color(0xffd9dadb);

  final Shader shader = const LinearGradient(
    colors: <Color>[Color(0xffffffff), Color(0xffB2DFDB)],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));
  final Shader secondaryShader = const LinearGradient(
    colors: <Color>[Color(0xff26A69A), Color(0xff009688)],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  final linearGradientBlue = const LinearGradient(
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
      colors: [Color(0xff80CBC4), Color(0xff00796B)],
      stops: [0.0, 1.0]);
  final linearGradientPurple = const LinearGradient(
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
      colors: [Color(0xff51087E), Color(0xff6C0BA9)],
      stops: [0.0, 1.0]);
}