import 'package:flutter/material.dart';
import 'package:smart_home_iotz/Presentation/Setting/setting.dart';
import 'package:smart_home_iotz/Presentation/addMember/add_member.dart';
import 'package:smart_home_iotz/Presentation/home/homeScreen.dart';
import 'package:smart_home_iotz/shared/component/logic.dart';
import 'package:smart_home_iotz/shared/component/presentationComponent.dart';
import 'package:smart_home_iotz/shared/cubit/main_cubit.dart';
import 'package:smart_home_iotz/shared/session/session.dart';
import 'package:smart_home_iotz/shared/style/appColors.dart';

Widget myDrawer(BuildContext context) => SafeArea(
  child: Container(
    width: MediaQuery.of(context).size.width * 0.7,
    height: MediaQuery.of(context).size.height,
    decoration: BoxDecoration(
      color: Appcolors.myBK(theme),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        bottomLeft: Radius.circular(10),
      ),
      boxShadow: [
        BoxShadow(
          offset: Offset(0, 4),
          color: Colors.black.withOpacity(0.2),
          blurRadius: 10,
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        children: [
          SizedBox(height: 20),
          myShortCutIcon(
            onpress: () {
              Navigator.pushReplacement(
                context,
                NavigateWithAnimation(child: Homescreen()),
              );
            },
            img: 'assets/images/Home active.png',
            txt: 'Home',
          ),
          myShortCutIcon(
            onpress: () {
              // Navigator.push(
              //   context,
              //   NavigateWithAnimation(child: Homescreen()),
              // );
            },
            img: 'assets/images/notifications.png',
            txt: 'Notifications',
          ),
          myShortCutIcon(
            onpress: () {
              BleCubit.get(
                context,
              ).getMembers(AppSession.overview.first.home.id);
              Navigator.push(
                context,
                NavigateWithAnimation(child: AddMember()),
              );
            },
            img: 'assets/images/users.png',
            txt: 'Members',
          ),
          myShortCutIcon(
            onpress: () {
              Navigator.push(context, NavigateWithAnimation(child: Setting()));
            },
            img: 'assets/images/settings.png',
            txt: 'Settings',
          ),
          const Spacer(),
          TextButton(
            onPressed: () {},
            child: Text('About Us', style: mystyle(size: 24)),
          ),
        ],
      ),
    ),
  ),
);

Widget myShortCutIcon({
  required VoidCallback onpress,
  required String img,
  required String txt,
}) => IconButton(
  onPressed: onpress,
  icon: Row(
    children: [
      Image.asset(img, width: 20, height: 20),
      const Spacer(),
      Text(txt, style: mystyle(size: 20)),
      const Spacer(),
    ],
  ),
);
