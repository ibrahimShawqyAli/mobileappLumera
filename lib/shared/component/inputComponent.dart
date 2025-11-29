import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_home_iotz/shared/component/presentationComponent.dart';
import 'package:smart_home_iotz/shared/style/appColors.dart';

Widget inputText(
  BuildContext context, {
  required TextEditingController controller,
  Widget? prefixIcon,
  Widget? suffixIcon,
  String? hintText,
  TextInputType keybaord = TextInputType.text,
  bool isSecure = false,
  String? Function(String?)? validate,
}) {
  return TextFormField(
    controller: controller,
    obscureText: isSecure,
    validator: validate,
    keyboardType: keybaord,
    style: TextStyle(fontSize: 16, color: Appcolors.grey),
    decoration: InputDecoration(
      label: Text(
        '$hintText',
        style: TextStyle(fontFamily: 'Costaline', color: Appcolors.grey),
      ),
      labelStyle: mystyle(size: 14, color: Colors.white),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: Appcolors.grey, // or any color you want
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: Appcolors.grey, // focus border color
          width: 2,
        ),
      ),
      fillColor: Appcolors.myBK(theme),
      filled: true,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    ),
  );
}
