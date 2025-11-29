import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smart_home_iotz/shared/cubit/main_cubit.dart';
import 'package:smart_home_iotz/shared/style/appColors.dart';

TextStyle mystyle({
  required double size,
  Color color = Appcolors.grey,
  bool isBold = false,
  bool isShadow = false,
}) => TextStyle(
  fontFamily: 'Costaline',
  fontSize: size,
  color: color,
  fontWeight: !isBold ? FontWeight.normal : FontWeight.bold,
  shadows: [
    isShadow
        ? Shadow(
          offset: Offset(2.0, 2.0), // horizontal & vertical offset
          blurRadius: 3.0, // softens the shadow
          color: Colors.grey, // shadow color
        )
        : Shadow(),
  ],
);

void showColorPicker(BuildContext context) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          title: Text('Pick Color RGB', style: mystyle(size: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ColorPicker(
                pickerColor: BleCubit.get(context).rgb,
                onColorChanged: (Color selected) {
                  BleCubit.get(context).pickingColor(selected);
                },
              ),
              const SizedBox(height: 10),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.send, color: BleCubit.get(context).rgb),
              ),
            ],
          ),
        ),
  );
}

Widget controllerItem(
  context, {
  required GestureTapDownCallback onpress1,
  required GestureTapDownCallback onpress2,
  required GestureTapUpCallback onRelease,
  Color myColor = Appcolors.baseColor,
  required double w,
  required String txt,
}) => SizedBox(
  width: MediaQuery.of(context).size.width,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        height: 70,
        width: w,
        decoration: BoxDecoration(
          color: Appcolors.baseColor3,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(50),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Center(
          child: Text(
            txt,
            style: mystyle(size: 25, color: Appcolors.baseColor, isBold: true),
          ),
        ),
      ),
      InkWell(
        onTapDown: onpress1,
        onTapCancel: () => onRelease,
        onTapUp: onRelease,
        child: CircleAvatar(
          radius: 30,
          backgroundColor: Appcolors.icon,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Image.asset('assets/images/arrowup.png'),
          ),
        ),
      ),

      InkWell(
        onTapDown: onpress2,
        onTapCancel: () => onRelease,
        onTapUp: onRelease,
        child: CircleAvatar(
          radius: 30,
          backgroundColor: Appcolors.icon,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Image.asset('assets/images/arrowdown.png'),
          ),
        ),
      ),
      SizedBox(width: w * 0.2),
    ],
  ),
);

Widget controllerMassage(
  context, {
  required GestureTapDownCallback onpress1,
  required GestureTapDownCallback onpress2,
  required GestureTapUpCallback onRelease,
  Color myColor = Appcolors.baseColor,
  required double w,
  required String txt,
}) => SizedBox(
  width: MediaQuery.of(context).size.width,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        height: 70,
        width: w,
        decoration: BoxDecoration(
          color: Appcolors.baseColor3,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(50),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Center(
          child: Text(
            txt,
            style: mystyle(size: 25, color: Appcolors.baseColor, isBold: true),
          ),
        ),
      ),
      Column(
        children: [
          InkWell(
            onTapDown: onpress1,
            onTapCancel: () => onRelease,
            onTapUp: onRelease,
            child: Container(
              width: 80,
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xff00bf63),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'Level 1',
                  style: mystyle(size: 18, color: Colors.white, isBold: true),
                ),
              ),
            ),
          ),
          SizedBox(height: 15),
          InkWell(
            onTapDown: onpress2,
            onTapCancel: () => onRelease,
            onTapUp: onRelease,
            child: Container(
              width: 80,
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xffffde59),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'Level 2',
                  style: mystyle(size: 18, color: Colors.white, isBold: true),
                ),
              ),
            ),
          ),
          SizedBox(height: 15),
          InkWell(
            onTapDown: onpress2,
            onTapCancel: () => onRelease,
            onTapUp: onRelease,
            child: Container(
              width: 80,
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xffffbd59),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'Level 3',
                  style: mystyle(size: 18, color: Colors.white, isBold: true),
                ),
              ),
            ),
          ),
        ],
      ),
      SizedBox(width: w * 0.2),
    ],
  ),
);

Widget controllerButton(
  context, {
  required GestureTapDownCallback onpress1,
  required GestureTapUpCallback onRelease,
  Color myColor = Appcolors.baseColor,
  required String txt,
}) => SizedBox(
  width: MediaQuery.of(context).size.width,
  child: Row(
    children: [
      Spacer(),
      InkWell(
        onTapDown: onpress1,
        onTapCancel: () => onRelease,
        onTapUp: onRelease,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: myColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Center(
              child: Text(
                txt,
                style: mystyle(size: 20, isBold: true, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      Spacer(),
    ],
  ),
);

Widget iconButton({required VoidCallback onpress, required IconData icon}) =>
    IconButton(
      onPressed: onpress,
      icon: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.transparent.withOpacity(0.3),
        child: Icon(icon, color: Colors.transparent.withOpacity(0.7)),
      ),
    );
Widget massageIcon(
  BuildContext context, {
  required String image1,
  required String image2,
  required VoidCallback onpress1,
  required VoidCallback onpress2,
}) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      IconButton(
        onPressed: onpress1,
        icon: CircleAvatar(
          radius: MediaQuery.of(context).size.width * 0.1,
          backgroundColor: Colors.transparent,
          child: Center(
            child: ClipOval(
              child: Image.asset(
                image1,
                width: MediaQuery.of(context).size.width * 0.2,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
      IconButton(
        onPressed: onpress2,
        icon: CircleAvatar(
          radius: MediaQuery.of(context).size.width * 0.1,
          backgroundColor: Colors.transparent,
          child: Center(
            child: ClipOval(
              child: Image.asset(
                image2,
                width: MediaQuery.of(context).size.width * 0.2,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    ],
  ),
);

void showToast(String msg) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.red,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
