import 'package:smart_home_iotz/Models/deviceModel/remoteDeviceModel.dart';
import 'package:smart_home_iotz/Models/homeModel/homeModel.dart';
import 'package:smart_home_iotz/Models/roomModel/remoteRoomModel.dart';

class HomeOverview {
  final HomeModel home;
  final List<RoomModelLite> rooms;
  final List<DeviceModelLite> devices;

  const HomeOverview({
    required this.home,
    required this.rooms,
    required this.devices,
  });

  factory HomeOverview.fromJson(Map<String, dynamic> json) => HomeOverview(
    home: HomeModel.fromJson(json['home'] as Map<String, dynamic>),
    rooms:
        (json['rooms'] as List<dynamic>? ?? const [])
            .map((e) => RoomModelLite.fromJson(e as Map<String, dynamic>))
            .toList(),
    devices:
        (json['devices'] as List<dynamic>? ?? const [])
            .map((e) => DeviceModelLite.fromJson(e as Map<String, dynamic>))
            .toList(),
  );

  Map<String, dynamic> toJson() => {
    'home': home.toJson(),
    'rooms': rooms.map((e) => e.toJson()).toList(),
    'devices': devices.map((e) => e.toJson()).toList(),
  };
}
