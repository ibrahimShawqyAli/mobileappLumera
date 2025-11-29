import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_iotz/Presentation/addMember/add_member.dart';
import 'package:smart_home_iotz/Presentation/addRoomDevice/addRoom.dart';
import 'package:smart_home_iotz/Presentation/drawer/drawer.dart';
import 'package:smart_home_iotz/Presentation/get%20Started/getstarted.dart';
import 'package:smart_home_iotz/Presentation/home/homeScreen.dart';
import 'package:smart_home_iotz/Presentation/pairingScreen/pairingScreen.dart';
import 'package:smart_home_iotz/shared/component/logic.dart';
import 'package:smart_home_iotz/shared/component/presentationComponent.dart';
import 'package:smart_home_iotz/shared/cubit/main_cubit.dart';
import 'package:smart_home_iotz/shared/cubit/main_state.dart';
import 'package:smart_home_iotz/shared/style/appColors.dart';

class Setting extends StatelessWidget {
  Setting({super.key});
  final GlobalKey<ScaffoldState> _keyState = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Appcolors.statusColor,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    double w = MediaQuery.of(context).size.width;
    var cubit = BleCubit.get(context);
    return BlocConsumer<BleCubit, BleState>(
      listener: (context, state) {
        if (state is BleWriteError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.err),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        if (state is BleConnected) {
          // Navigator.pushReplacement(
          //   context,
          //   NavigateWithAnimation(child: Homescreen()),
          // );
        }
      },
      builder: (context, state) {
        return Scaffold(
          key: _keyState,
          endDrawer: myDrawer(context),
          backgroundColor: Appcolors.myBK(theme),

          body: SafeArea(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              NavigateWithAnimation(
                                child: Homescreen(),
                                isRight: true,
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: Appcolors.grey,
                            size: 25,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              NavigateWithAnimation(child: GetStarted()),
                            );
                          },
                          icon: Icon(
                            Icons.logout,
                            color: Appcolors.grey,
                            size: 30,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _keyState.currentState!.openEndDrawer();
                          },
                          icon: Icon(
                            Icons.menu,
                            color: Appcolors.grey,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Settings', style: mystyle(size: 25)),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 150,
                          child: AnimatedToggleSwitch<bool>.dual(
                            current: theme,
                            first: false,
                            second: true,
                            spacing: 4.0,
                            style: ToggleStyle(
                              borderColor: Colors.transparent,
                              backgroundGradient:
                                  theme
                                      ? LinearGradient(
                                        colors: [Colors.purple, Colors.pink],
                                      )
                                      : LinearGradient(
                                        colors: [
                                          Colors.black87,
                                          Colors.black45,
                                        ],
                                      ),
                              indicatorColor: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            iconBuilder:
                                (value) =>
                                    value
                                        ? Icon(
                                          Icons.wb_sunny,
                                          color: Colors.purple,
                                        )
                                        : Icon(
                                          Icons.nightlight,
                                          color: Colors.black,
                                        ),
                            textBuilder:
                                (value) => Center(
                                  child: Text(
                                    value ? "DAYMODE" : "NIGHTMODE",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            onChanged: (value) {
                              cubit.isDark(value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  IconButton(
                    onPressed: () {
                      cubit.getAllRooms();
                      Navigator.push(
                        context,
                        NavigateWithAnimation(child: AddRoomScreen()),
                      );
                    },
                    icon: Container(
                      height: 60,
                      width: (w / 1.1),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Appcolors.grey),
                        borderRadius: BorderRadius.circular(15),
                        color: Appcolors.white,
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 4),
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Add Room',
                          style: mystyle(size: 20, isBold: true),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      cubit.getSSid();
                      cubit.getAllRooms();
                      Navigator.push(
                        context,
                        NavigateWithAnimation(child: Pairingscreen()),
                      );
                    },
                    icon: Container(
                      height: 60,
                      width: (w / 1.1),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Appcolors.grey),
                        borderRadius: BorderRadius.circular(15),
                        color: Appcolors.white,
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 4),
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.white,
                              child: ClipOval(
                                child: Image.asset('assets/images/socket.gif'),
                              ),
                            ),
                            const Spacer(),
                            Center(
                              child: Text(
                                'Set up Device',
                                style: mystyle(size: 20, isBold: true),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
