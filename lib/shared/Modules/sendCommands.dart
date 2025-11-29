import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smart_home_iotz/Models/deviceModel/deviceModel.dart';
import 'package:smart_home_iotz/shared/WS/webSocketHelper.dart';
import 'package:smart_home_iotz/shared/web/hub.dart';

void sendToESP({
  required DeviceModel device,
  required dynamic state,
  required SocketService socket,
}) {
  final s = SocketHub.maybe;
  if (s == null) {
    debugPrint('[sendControl] ❌ Socket not ready. Did you call connectWs()?');
    return;
  }

  final msg = {
    "type": "control",
    "device_pk": device.serverId,
    "payload": {
      "pin": device.pin,
      device.device_type == "rgb" ? "color" : "state": state,
    },
  };

  try {
    final txt = jsonEncode(msg);
    debugPrint('[sendControl] → $txt');
    s.channel.sink.add(txt);
  } catch (e) {
    debugPrint('[sendControl] ❌ $e');
  }
}
