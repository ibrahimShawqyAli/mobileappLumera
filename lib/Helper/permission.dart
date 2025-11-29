import 'package:permission_handler/permission_handler.dart';

class PermissionBLE {
  static Future<bool> requestPermissions() async {
    var status1 = await Permission.bluetoothScan.request();
    var status2 = await Permission.bluetoothConnect.request();
    var status3 = await Permission.locationWhenInUse.request();

    return status1.isGranted && status2.isGranted && status3.isGranted;
  }
}
