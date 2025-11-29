import 'package:flutter/material.dart';
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:smart_home_iotz/Models/deviceModel/deviceModel.dart';
import 'package:smart_home_iotz/Presentation/home/homeScreen.dart';
import 'package:smart_home_iotz/shared/Modules/sendCommands.dart';
import 'package:smart_home_iotz/shared/WS/webSocketHelper.dart';
import 'package:smart_home_iotz/shared/component/list.dart';
import 'package:smart_home_iotz/shared/component/logic.dart';
import 'package:smart_home_iotz/shared/component/modeSelector.dart';
import 'package:smart_home_iotz/shared/component/presentationComponent.dart';
import 'package:smart_home_iotz/shared/cubit/main_cubit.dart';
import 'package:smart_home_iotz/shared/style/appColors.dart';

class RgbScreen extends StatefulWidget {
  const RgbScreen({super.key, required this.socket, required this.mydevice});
  final DeviceModel mydevice;
  final SocketService socket;
  @override
  State<RgbScreen> createState() => _RgbScreenState();
}

class _RgbScreenState extends State<RgbScreen> {
  final _controller = CircleColorPickerController(initialColor: Colors.blue);
  int mode = 0;
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h =
        MediaQuery.of(context).size.height > 750
            ? MediaQuery.of(context).size.height
            : 750;

    return Scaffold(
      backgroundColor: Appcolors.myBK(theme),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Appcolors.grey,
                          size: 25,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.menu, color: Appcolors.grey, size: 30),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Text('Lights control', style: mystyle(size: 30)),
                        Spacer(),
                        IconButton(
                          onPressed: () {
                            sendToESP(
                              // deviceId: widget.mydevice.device_unit_id,
                              // pin: widget.mydevice.pin,
                              device: widget.mydevice,
                              state: "#${_controller.color.toHexString()}",
                              socket: widget.socket,
                            );
                          },
                          icon: Icon(Icons.send, color: Appcolors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Quick Selection', style: mystyle(size: 14)),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    colorIcon(
                      gradient: [Color(0xfffd415a), Color(0xfffe7783)],
                      onpress: () {
                        setState(() {
                          _controller.color = Color(0xfffd415a);
                        });
                      },
                    ),
                    colorIcon(
                      gradient: [Color(0xff06c230), Color(0xff72f87e)],
                      onpress: () {
                        setState(() {
                          _controller.color = Color(0xff06c230);
                        });
                      },
                    ),
                    colorIcon(
                      gradient: [Color(0xff69cb39), Color(0xff69fb86)],
                      onpress: () {
                        setState(() {
                          _controller.color = Color(0xff69fb86);
                        });
                      },
                    ),
                    colorIcon(
                      gradient: [Color(0xff335ec6), Color(0xff338bc6)],
                      onpress: () {
                        setState(() {
                          _controller.color = Color(0xff335ec6);
                        });
                      },
                    ),
                    colorIcon(
                      gradient: [
                        Color(0xffe0c44e),
                        Color(0xfff0db79),
                      ], // yellow gradient
                      onpress: () {
                        setState(() {
                          _controller.color = Color(0xffe0c44e);
                        });
                      },
                    ),
                    colorIcon(
                      gradient: [
                        Color(0xff7e3bdc),
                        Color(0xffa867f5),
                      ], // purple gradient
                      onpress: () {
                        setState(() {
                          _controller.color = Color(0xff7e3bdc);
                        });
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Text(
                          '-',
                          style: TextStyle(
                            fontFamily: 'Costaline',
                            color: Appcolors.grey,
                            fontSize: 35,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                      ),

                      Container(
                        width: w * 0.7,
                        height: w * 0.7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(width: 1, color: Appcolors.grey),
                        ),
                        child: Center(
                          child: CircleColorPicker(
                            controller: _controller,
                            onChanged: (color) {
                              setState(() {});
                            },
                            size: Size(0.7 * w - 10, 0.7 * w - 10),
                            strokeWidth: 12,
                            thumbSize: 36,
                            textStyle: mystyle(
                              size: 12,
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Text(
                          '+',
                          style: TextStyle(
                            fontFamily: 'Costaline',
                            color: Appcolors.grey,
                            fontSize: 35,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Click to choose', style: mystyle(size: 16)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    colorRectangle(
                      gradient: [
                        Color(0xffffd600),
                        Color(0xffff4e50),
                      ], // Yellow to Red (R)
                      onpress: () {
                        setState(() {
                          _controller.color = Color(0xffff4e50);
                        });
                      },
                      text: 'R',
                    ),
                    SizedBox(width: 12),
                    colorRectangle(
                      gradient: [
                        Color(0xff00e4d0),
                        Color(0xff5983e8),
                      ], // Cyan to Blue-Green (G)
                      onpress: () {
                        setState(() {
                          _controller.color = Color(0xff00e4d0);
                        });
                      },
                      text: 'G',
                    ),
                    SizedBox(width: 12),
                    colorRectangle(
                      gradient: [
                        Color(0xff2193b0),
                        Color(0xff6dd5ed),
                      ], // Blue to Light Blue (B)
                      onpress: () {
                        setState(() {
                          _controller.color = Color(0xff2193b0);
                        });
                      },
                      text: 'B',
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 25,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MODE',
                            style: mystyle(size: 18, color: Color(0xff7c7c7c)),
                          ),
                          CustomThreeStepSlider(
                            onChanged: (value) {
                              setState(() {
                                mode = value;
                              });
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'STATIC',
                                style: mystyle(
                                  size: 18,
                                  color:
                                      mode == 0
                                          ? Color(0xff7c7c7c)
                                          : Appcolors.grey,
                                ),
                              ),
                              Text(
                                'FADE',
                                style: mystyle(
                                  size: 18,
                                  color:
                                      mode == 1
                                          ? Color(0xff7c7c7c)
                                          : Appcolors.grey,
                                ),
                              ),
                              Text(
                                'WAVE',
                                style: mystyle(
                                  size: 18,
                                  color:
                                      mode == 2
                                          ? Color(0xff7c7c7c)
                                          : Appcolors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
