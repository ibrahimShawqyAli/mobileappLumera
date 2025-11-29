import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:smart_home_iotz/Models/deviceModel/deviceModel.dart';
import 'package:smart_home_iotz/Models/members/memberModel.dart';
import 'package:smart_home_iotz/Models/roomModel/roomModel.dart';
import 'package:smart_home_iotz/shared/component/presentationComponent.dart';
import 'package:smart_home_iotz/shared/cubit/main_cubit.dart';
import 'package:smart_home_iotz/shared/cubit/main_state.dart';
import 'package:smart_home_iotz/shared/style/appColors.dart';

Widget roomList(List<RoomModel> myList) => ListView.separated(
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(),
  itemCount: myList.length,
  separatorBuilder: (context, index) => SizedBox(height: 10),
  itemBuilder: (context, index) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Appcolors.myBK(theme),
        border: Border.all(width: 0.5, color: Appcolors.grey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey[300],
              child: ClipOval(
                child: FutureBuilder(
                  future: precacheImage(
                    AssetImage(myList[index].iconPath),
                    context,
                  ).then((_) => true).catchError((_) => false),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.data == true) {
                      return Image.asset(
                        myList[index].iconPath,
                        fit: BoxFit.cover,
                        width: 50,
                        height: 50,
                      );
                    } else {
                      return Icon(
                        Icons.image,
                        size: 30,
                        color: Colors.grey[600],
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(myList[index].name, style: mystyle(size: 18)),
          ],
        ),
      ),
    );
  },
);

Widget deviceList(List<DeviceModel> myList, List<RoomModel> myRoomList) =>
    ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: myList.length,
      separatorBuilder: (context, index) => SizedBox(height: 10),
      itemBuilder: (context, index) {
        return Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Appcolors.myBK(theme),
            border: Border.all(width: 0.5, color: Appcolors.grey),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: Offset(4, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.black,
                  child: FutureBuilder(
                    future: precacheImage(
                      AssetImage(myList[index].iconPath),
                      context,
                    ).then((_) => true).catchError((_) => false),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.data == true) {
                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Image.asset(
                            myList[index].iconPath,
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                          ),
                        );
                      } else {
                        return Icon(
                          Icons.image,
                          size: 30,
                          color: Colors.grey[600],
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Text(myList[index].name, style: mystyle(size: 16)),
                const Spacer(),
                Text(
                  ' | ${getRoomNameById(myList[index].roomId, myRoomList)}',
                  style: mystyle(size: 14),
                ),
              ],
            ),
          ),
        );
      },
    );

Widget memberList(List<MemberModel> myMemberList) => ListView.separated(
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(),
  itemCount: myMemberList.length,
  separatorBuilder: (context, index) => SizedBox(height: 10),
  itemBuilder: (context, index) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Appcolors.myBK(theme),
        border: Border.all(width: 0.5, color: Appcolors.grey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.black,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(myMemberList[index].name, style: mystyle(size: 16)),
          ],
        ),
      ),
    );
  },
);

String getRoomNameById(int roomId, List<RoomModel> rooms) {
  final room = rooms.firstWhere(
    (element) => element.id == roomId,
    orElse: () => RoomModel.empty(),
  );
  return room.name;
}

Widget colorIcon({
  required List<Color> gradient,
  required VoidCallback onpress,
}) => IconButton(
  onPressed: onpress,
  icon: Container(
    width: 35,
    height: 35,
    decoration: BoxDecoration(
      border: Border.all(width: 0.5, color: Appcolors.grey),
      borderRadius: BorderRadius.circular(5),
      gradient: LinearGradient(
        colors: gradient,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
    ),
  ),
);
Widget colorRectangle({
  required List<Color> gradient,
  required VoidCallback onpress,
  required String text,
}) => IconButton(
  onPressed: onpress,
  icon: Container(
    width: 70,
    height: 30,
    decoration: BoxDecoration(
      border: Border.all(width: 0.5, color: Appcolors.grey),
      borderRadius: BorderRadius.circular(5),
      gradient: LinearGradient(
        colors: gradient,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
    ),
    child: Center(
      child: Text(text, style: mystyle(size: 16, color: Colors.white)),
    ),
  ),
);
Widget deviceListBLE(
  BuildContext context, {
  required String pass,
  required List<BluetoothDevice> devicesList,
  Color color = Appcolors.listBackgroudColor,
}) => ListView.separated(
  itemCount: devicesList.length,
  physics: const BouncingScrollPhysics(),
  shrinkWrap: true,
  separatorBuilder: (context, index) => const SizedBox(height: 10),
  itemBuilder:
      (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: [Color(0xff7144fe), Color(0xffab4df3), Color(0xfffd5ae5)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bluetooth, color: Colors.white),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              devicesList[index].advName,
                              style: mystyle(
                                size: 16,
                                isBold: true,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${devicesList[index].remoteId}',
                        style: mystyle(size: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                BlocConsumer<BleCubit, BleState>(
                  listener: (context, state) {
                    // TODO: implement listener
                  },
                  builder: (context, state) {
                    IconData icon = Icons.bluetooth_connected_sharp;
                    if (BleCubit.get(context).idTryConnected ==
                        devicesList[index].advName) {
                      if (state is BleTryConnect) {
                        icon = Icons.wifi_protected_setup;
                      }
                      if (state is BleConnected) {
                        icon = Icons.admin_panel_settings;
                      }
                      if (state is BleDisconnected) {
                        icon = Icons.done;
                      }
                    }
                    return IconButton(
                      onPressed: () {
                        final cubit = BleCubit.get(context);
                        final device = devicesList[index];

                        showDialog(
                          context: context,
                          builder: (ctx) {
                            final TextEditingController nameController =
                                TextEditingController(text: device.advName);

                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              backgroundColor: Appcolors.myBK(theme),
                              title: Text(
                                'Set device name',
                                style: mystyle(
                                  size: 18,
                                  isBold: true,
                                  color: Appcolors.grey,
                                ),
                              ),
                              content: TextField(
                                controller: nameController,
                                style: mystyle(size: 16, color: Appcolors.grey),
                                cursorColor: Appcolors.grey,
                                decoration: InputDecoration(
                                  labelText: 'Nickname',
                                  labelStyle: mystyle(
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.white24,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Appcolors.grey,
                                    ),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.edit,
                                    color: Appcolors.grey,
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: Text(
                                    'Cancel',
                                    style: mystyle(
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: Colors.pinkAccent,
                                  ),
                                  onPressed: () {
                                    String nickname =
                                        nameController.text.trim();
                                    if (nickname.isEmpty) {
                                      nickname = device.advName; // fallback
                                    }

                                    Navigator.pop(ctx); // اقفل الـ dialog

                                    cubit.connect(device, pass, nickname);
                                  },
                                  child: Text(
                                    'Setup',
                                    style: mystyle(
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: Icon(icon, size: 30, color: Colors.white),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
);

Widget myRoomDropMenu(BuildContext context) {
  final cubit = BleCubit.get(context);
  final rooms =
      cubit.myRoomsList
          .where((r) => r.id != -1 && r.name.toLowerCase() != "public")
          .toList();

  return DropdownButtonHideUnderline(
    child: DropdownButton2<int>(
      isExpanded: true,
      hint: Row(
        children: [
          Icon(Icons.meeting_room, size: 18, color: Appcolors.white),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Select Room',
              style: mystyle(size: 16, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      value: cubit.selectedRoomServerId,
      items:
          rooms
              .map(
                (room) => DropdownMenuItem<int>(
                  value: room.serverId,
                  child: Text(
                    room.name,
                    style: mystyle(size: 16, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
      onChanged: (value) {
        if (value == null) return;
        cubit.setSelectedRoomServerId(value);
      },
      buttonStyleData: ButtonStyleData(
        height: 55,
        width: double.infinity,
        padding: EdgeInsets.only(left: 14, right: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff7144fe), Color(0xffab4df3), Color(0xfffd5ae5)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
      ),
      iconStyleData: IconStyleData(
        icon: Icon(Icons.arrow_drop_down, color: Appcolors.white),
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff7144fe), Color(0xffab4df3), Color(0xfffd5ae5)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        offset: Offset(0, -5),
        scrollbarTheme: ScrollbarThemeData(
          radius: Radius.circular(40),
          thickness: MaterialStateProperty.all(4),
          thumbVisibility: MaterialStateProperty.all(true),
        ),
      ),
      menuItemStyleData: MenuItemStyleData(
        height: 45,
        padding: EdgeInsets.symmetric(horizontal: 14),
      ),
    ),
  );
}
