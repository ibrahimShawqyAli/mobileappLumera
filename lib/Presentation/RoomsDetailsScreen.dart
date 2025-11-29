import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_iotz/Presentation/addRoomDevice/addRoom.dart';
import 'package:smart_home_iotz/Presentation/drawer/drawer.dart';
import 'package:smart_home_iotz/Presentation/home/homeScreen.dart';
import 'package:smart_home_iotz/shared/Modules/sendCommands.dart';
import 'package:smart_home_iotz/shared/WS/webSocketHelper.dart';
import 'package:smart_home_iotz/shared/component/controlComponent/controlComponent.dart';
import 'package:smart_home_iotz/shared/component/logic.dart';
import 'package:smart_home_iotz/shared/component/menus.dart';
import 'package:smart_home_iotz/shared/component/presentationComponent.dart';

import 'package:smart_home_iotz/shared/cubit/main_cubit.dart';
import 'package:smart_home_iotz/shared/cubit/main_state.dart';
import 'package:smart_home_iotz/shared/style/appColors.dart';
import 'package:smart_home_iotz/shared/variables/variables.dart';
import 'package:smart_home_iotz/shared/web/hub.dart';
import 'package:smart_home_iotz/shared/web/socket.dart';

class RoomDetailsScreen extends StatefulWidget {
  RoomDetailsScreen({
    super.key,
    required this.roomName,
    required this.roomId,
    required this.roommImage,
  });
  final String roomName;
  final int roomId;
  final String roommImage;

  @override
  State<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  final GlobalKey<ScaffoldState> _keyState = GlobalKey<ScaffoldState>();

  final socket = SocketHub.I;
  @override
  void initState() {
    super.initState();
    //  socket = SocketService(myWebSocketServer); // ✅ Proper place to initialize
  }

  @override
  void dispose() {
    // socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    const double itemWidth = 150;
    final int crossAxisCount = (w / itemWidth).floor().clamp(2, 6);
    var cubit = BleCubit.get(context);
    return Scaffold(
      key: _keyState,
      endDrawer: myDrawer(context),
      backgroundColor: Appcolors.myBK(theme),
      body: BlocConsumer<BleCubit, BleState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        builder: (context, state) {
          return SafeArea(
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
                            NavigateWithAnimation(
                              child: AddRoomScreen(
                                creation_of_room: false,
                                serverID: widget.roomId,
                                name: widget.roomName,
                              ),
                              isRight: true,
                            ),
                          );
                        },
                        icon: Icon(Icons.edit, color: Appcolors.grey, size: 25),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () {
                          _keyState.currentState!.openEndDrawer();
                        },
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
                    child: Text(widget.roomName, style: mystyle(size: 25)),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.all(12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1, // You can tweak this
                    ),
                    itemCount: cubit.mydevices.length,
                    itemBuilder: (context, index) {
                      print("pin : ${cubit.mydevices[index].device_type}");
                      return deviceControl(
                        context: context,
                        d: cubit.mydevices[index],
                        socket: socket,
                        onStateChange: (value) {
                          sendToESP(
                            // deviceId: cubit.mydevices[index].device_unit_id,
                            // pin: cubit.mydevices[index].pin,
                            device: cubit.mydevices[index],
                            state: value ? 'on' : 'off',
                            socket: socket,
                          );

                          // 2) Update UI state
                          setState(() {
                            cubit.mydevices[index].state = value;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
