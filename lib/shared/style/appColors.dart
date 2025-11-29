import 'package:flutter/material.dart';

bool theme = true;

class Appcolors {
  static const Color statusColor = Colors.black;
  static const Color baseColor = Color(0xff02acf7);
  static const Color white = Color(0xfffefefe);
  static const Color grey = Color(0xffc1c1c1);

  static const Color listBackgroudColor = Color(0xfff7f7f7);
  static const Color buttonRelax = Color(0xff0a71fa);
  static const Color baseColor2 = Color(0xffe8d2c6);
  static const Color baseColor3 = Color(0xffd7c6c1);
  static const Color icon = Color(0xfff11d1d);
  static Color yellow = Color(0xffffcc2f);

  static const Color RgbComponentColor = Colors.black;

  static Color myBK(bool theme) => theme ? Colors.white : Color(0xff2f2f2f);
  static List<Color> backgroud = [
    Color(0xff02acf7),
    Color(0xff02acf7),
    Color(0xff02acf7),
    Color(0xff02acf7),
    Color(0xff02acf7),
    Color(0xff4771f3),
    Color(0xff6656f2),
  ];
  static List<Color> login = [
    Color(0xff810ce4),
    Color(0xffd62aa6),
    Color(0xffd62aa6),
    Color(0xffd329a8),
  ];
  static List<Color> buttons = [Colors.purple, Colors.pink];
  static List<Color> roomIcon = [
    Color(0xff77A1D3),
    Color(0xff79CBCA),
    Color(0xffE684AE),
  ];
  static List<Color> backGroundGetStarted = [
    Color(0xffe5e5e5),
    Color(0xffe9e9e9),
    Color(0xff999a9d),
  ];
  static List<Color> loginGradient = [
    Color(0xffcbcaa5),
    Color(0xffcbcaa5),
    Color(0xffcbcaa5),
    Color(0xffcbcaa5),
    Color(0xff818d7b),
    Color(0xff334d50),
  ];
}
