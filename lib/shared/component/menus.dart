import 'package:flutter/material.dart';
import 'package:smart_home_iotz/Presentation/EditDeviceScreen/EditDeviceScreen.dart';
import 'package:smart_home_iotz/Presentation/setTimerDevice/SetTimerScreen.dart';
import 'package:smart_home_iotz/shared/component/logic.dart';
import 'package:smart_home_iotz/shared/cubit/main_cubit.dart';

Widget myPop(
  BuildContext context,
  deviceID,
  roomId,
  String unitID,
) => PopupMenuButton<int>(
  icon: Icon(Icons.more_vert, color: Colors.white),
  offset: Offset(0, 40), // Controls the position beside the 3-dot icon
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  color: Colors.white,
  itemBuilder:
      (context) => [
        PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.blue),
              SizedBox(width: 10),
              Text("Edit"),
            ],
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 10),
              Text("Delete"),
            ],
          ),
        ),
        PopupMenuItem(
          value: 3,
          child: Row(
            children: [
              Icon(Icons.timer, color: Colors.green),
              SizedBox(width: 10),
              Text("Timer"),
            ],
          ),
        ),
      ],
  onSelected: (value) {
    if (value == 1) {
      Navigator.push(
        context,
        NavigateWithAnimation(
          child: EditDeviceScreen(deviceId: deviceID),
          isRight: true,
        ),
      );
    } else if (value == 2) {
      final cubit = BleCubit.get(context);
      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              actionsPadding: const EdgeInsets.only(bottom: 10, right: 10),
              title: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 28,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Delete Device?",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              content: Text(
                "Are you sure you want to delete this device? This action cannot be undone.",
                style: TextStyle(fontSize: 15),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    cubit.deleteDevice(deviceID, roomId);
                  },
                  icon: Icon(Icons.delete_forever, size: 18),
                  label: Text("Yes, Delete"),
                ),
              ],
            ),
      );
    } else if (value == 3) {
      Navigator.pushReplacement(
        context,
        NavigateWithAnimation(child: SetTimerScreen(deviceId: unitID)),
      );
    }
  },
);
