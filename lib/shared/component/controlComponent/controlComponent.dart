import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:smart_home_iotz/Models/deviceModel/deviceModel.dart';
import 'package:smart_home_iotz/Presentation/rgbScreen/rgb_screen.dart';
import 'package:smart_home_iotz/shared/WS/webSocketHelper.dart';
import 'package:smart_home_iotz/shared/component/logic.dart';
import 'package:smart_home_iotz/shared/component/menus.dart';
import 'package:smart_home_iotz/shared/component/presentationComponent.dart';
import 'package:smart_home_iotz/shared/style/appColors.dart';

Widget deviceControl({
  required BuildContext context,
  required DeviceModel d,
  required SocketService socket,
  required ValueChanged<bool> onStateChange,
}) {
  final type = d.device_type;

  if (type == 'rgb') {
    return rgbComponent(
      context,
      d: d,
      socket: socket,
    ); //RgbComponent(device: d, socket: socket);
  } else if (type == 'ir') {
    return irComponent(
      d: d,
      socket: socket,
    ); //IrRemoteComponent(device: d, socket: socket);
  } else {
    // default = On/Off
    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
      width: 150,
      height: 120,
      decoration: BoxDecoration(
        color: d.state ? const Color(0xFF3A3A3C) : Colors.black,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  d.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: mystyle(size: 16, color: Colors.white),
                ),
              ),
              myPop(context, d.id, d.roomId, d.device_unit_id),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                height: 70,
                width: 70,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(d.iconPath),
                ),
              ),
              const Spacer(),
              Switch(
                value: d.state,
                activeColor: Colors.white,
                onChanged: onStateChange,
              ),
            ],
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              d.state ? 'On' : 'Off',
              style: mystyle(size: 16, isBold: true, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

Widget rgbComponent(
  BuildContext context, {
  required DeviceModel d,
  required SocketService socket,
}) => InkWell(
  onTap: () {
    Navigator.push(
      context,
      NavigateWithAnimation(child: RgbScreen(mydevice: d, socket: socket)),
    );
  },
  child: Container(
    width: 120,
    height: 120,
    decoration: BoxDecoration(
      color: Appcolors.RgbComponentColor,
      shape: BoxShape.circle,
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(d.iconPath),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              d.name,
              style: mystyle(size: 22, color: Colors.white, isBold: true),
            ),
          ),
        ),
      ],
    ),
  ),
);

Widget irComponent({required DeviceModel d, required SocketService socket}) =>
    InkWell(
      onTap: () {},
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Appcolors.RgbComponentColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(d.iconPath, width: 50, height: 50),
              SizedBox(height: 10),
              Expanded(
                child: Center(
                  child: Text(
                    d.name,
                    style: mystyle(size: 22, color: Colors.white, isBold: true),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
