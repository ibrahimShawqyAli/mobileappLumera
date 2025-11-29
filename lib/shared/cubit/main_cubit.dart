import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:smart_home_iotz/Helper/permission.dart';
import 'package:smart_home_iotz/Models/deviceDeteialsPairing/devicePairingDetails.dart';
import 'package:smart_home_iotz/Models/deviceModel/deviceModel.dart';
import 'package:smart_home_iotz/Models/homeModel/home_overview.dart';
import 'package:smart_home_iotz/Models/members/memberModel.dart';
import 'package:smart_home_iotz/Models/roomModel/roomModel.dart';
import 'package:smart_home_iotz/Models/userModel/userModel.dart';
import 'package:smart_home_iotz/shared/Cache/cacheHelper.dart';
import 'package:smart_home_iotz/shared/DB/db.dart';
import 'package:smart_home_iotz/shared/Remote/dioHelper.dart';
import 'package:smart_home_iotz/shared/cubit/main_state.dart';
import 'package:smart_home_iotz/shared/session/session.dart';
import 'package:smart_home_iotz/shared/style/appColors.dart';
import 'package:smart_home_iotz/shared/variables/variables.dart';

class BleCubit extends Cubit<BleState> {
  BleCubit() : super(BleInitial());
  static BleCubit get(BuildContext context) => BlocProvider.of(context);
  IconData connectedIcon = Icons.bluetooth_disabled_outlined;
  //
  bool isConnected = false;
  bool isAnimationDone = false;
  Color rgb = Colors.white;
  void finishAnimation(bool state) {
    isAnimationDone = state;
    emit(BLERefreshUI());
  }

  void isDark(bool state) {
    theme = state;
    emit(BLERefreshUI());
  }

  void pickingColor(Color color) {
    rgb = color;
    emit(BlePickingColor());
  }

  void addRoom({
    required String name,
    required String path,
    required bool is_private,
  }) async {
    await DioHelper.post(
          room_route_create,
          data: {
            "home_id": AppSession.overview.first.home.id,
            "name": name,
            "icon_path": path,
            "is_private": is_private,
          },
          auth: true,
        )
        .then((value) {
          emit(ServerAddRoom());
        })
        .catchError((e) {
          emit(ServerAddRoomError(err: 'Error : ${e.toString()}'));
        });
  }

  void editRoom({
    required int id,
    required String name,
    required String path,
    required bool is_private,
  }) async {
    await DioHelper.put(
          "$room_route_update$id",
          data: {"name": name, "icon_path": path, "is_private": is_private},
          auth: true,
        )
        .then((value) {
          print(value.statusCode);
          if (value.statusCode == 200) {
            emit(ServerEditRoom());
          }
        })
        .catchError((e) {
          print(e);
          emit(ServerEditRoomError(err: 'Error: ${e.toString()}'));
        });
  }

  void deleteRoom(int id) async {
    await DBHelper.deleteRoom(id)
        .then((_) {
          emit(DBTransiactionState('Room deleted'));
        })
        .catchError((e) {
          emit(DBTransiactionErrorState('Error: ${e.toString()}'));
        });
  }

  List<MemberModel> membersList = [];

  Future<void> getMembers(int homeId) async {
    emit(LoadingMembersState());

    try {
      final response = await DioHelper.get<Map<String, dynamic>>(
        "/homes-invitation/$homeId/members",
        auth: true,
      );

      print("===== MEMBERS API RESPONSE =====");
      print("STATUS: ${response.statusCode}");
      print("DATA  : ${response.data}");

      if (response.statusCode == 200) {
        final body = response.data ?? {};

        // لو انت ملتزم إن الAPI يرجع status, message, members
        final bool ok = body['status'] as bool? ?? false;
        if (!ok) {
          final msg = body['message']?.toString() ?? 'Failed to load members';
          emit(ErrorMembersState(msg));
          return;
        }

        final List rawList = body['members'] as List? ?? [];

        membersList =
            rawList
                .map((m) => MemberModel.fromJson(m as Map<String, dynamic>))
                .toList();

        emit(LoadedMembersState());
      } else {
        emit(ErrorMembersState("HTTP ${response.statusCode}"));
      }
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final data = e.response?.data;
      print("===== MEMBERS API DIO ERROR =====");
      print("STATUS: $code");
      print("DATA  : $data");
      print("MSG   : ${e.message}");

      emit(ErrorMembersState("HTTP $code"));
    } catch (e) {
      print("===== MEMBERS UNKNOWN ERROR =====");
      print(e);
      emit(ErrorMembersState(e.toString()));
    }
  }

  Future<void> addMember({
    required int homeId,
    required String email,
    required String name,
    required String password,
    required String role,
    required List<int> allowedRoomIds,
  }) {
    emit(LoadingMembersState());

    return DioHelper.post<Map<String, dynamic>>(
          "/homes-invitation/$homeId",
          data: {
            "name": name,
            "email": email,
            "password": password,
            "role": role,
            "allowed_room_ids": allowedRoomIds,
          },
          auth: true,
        )
        .then((response) {
          print("===== ADD MEMBER API RESPONSE =====");
          print("STATUS: ${response.statusCode}");
          print("DATA  : ${response.data}");

          if (response.statusCode == 201 || response.statusCode == 200) {
            final body = response.data ?? {};

            final bool ok = body['status'] as bool? ?? false;
            final msg = body['message']?.toString() ?? 'Unknown';

            if (!ok) {
              emit(
                ErrorMembersState(msg.isEmpty ? "Failed to add member" : msg),
              );
              return;
            }

            // بعد الإضافة الناجحة رجّع حمّل الليست من جديد
            getMembers(homeId);
          } else {
            emit(ErrorMembersState("HTTP ${response.statusCode}"));
          }
        })
        .catchError((e) {
          if (e is DioException) {
            final code = e.response?.statusCode;
            final data = e.response?.data;
            print("===== ADD MEMBER API DIO ERROR =====");
            print("STATUS: $code");
            print("DATA  : $data");
            print("MSG   : ${e.message}");

            emit(ErrorMembersState("HTTP $code"));
          } else {
            print("===== ADD MEMBER UNKNOWN ERROR =====");
            print(e);
            emit(ErrorMembersState(e.toString()));
          }
        });
  }

  void addDevice({
    required String name,
    required String unitId,
    required String type,
    required String path,
    required int roomId,
  }) async {
    await DBHelper.addDevice(name, unitId, type, roomId, path)
        .then((value) {
          if (value > 0) {
            emit(DBTransiactionState('Device "$name" added'));
            getAllDevices();
          }
        })
        .catchError((e) {
          emit(DBTransiactionErrorState('Error: ${e.toString()}'));
        });
  }

  void editDevice({
    required int id,
    required String name,
    required String type,
    required String iconPath,
    required int roomId,
  }) async {
    try {
      final result = await DBHelper.editDevice(
        id,
        newName: name,
        newType: type,
        newIconPath: iconPath,
        newRoomId: roomId,
      );

      if (result > 0) {
        emit(DBTransiactionState('Device "$name" updated successfully'));
        getAllDevices(); // Refresh UI list
      } else {
        emit(DBTransiactionErrorState('No changes were made.'));
      }
    } catch (e) {
      emit(DBTransiactionErrorState('Error editing device: ${e.toString()}'));
    }
  }

  void deleteDevice(int deviceId, int roomId) async {
    try {
      final db = await DBHelper.deleteDevice(deviceId);
      if (db > 0) {
        emit(DBTransiactionState('Device deleted'));
        getRoomDevices(roomId); // refresh device list in UI
      } else {
        emit(DBTransiactionErrorState('No device was deleted.'));
      }
    } catch (e) {
      emit(DBTransiactionErrorState('Error deleting device: ${e.toString()}'));
    }
  }

  void assignDeviceToRoom({required int deviceId, required int roomId}) async {
    await DBHelper.assignDeviceToRoom(deviceId, roomId)
        .then((value) {
          if (value > 0) {
            emit(DBTransiactionState('Device reassigned'));
          }
        })
        .catchError((e) {
          emit(DBTransiactionErrorState('Error: ${e.toString()}'));
        });
  }

  //
  List<RoomModel> myRoomsList = [];
  int? selectedRoomServerId;

  void setSelectedRoomServerId(int id) {
    selectedRoomServerId = id;
    emit(BLERefreshUI());
  }

  void getAllRooms() async {
    await DBHelper.getAllRooms()
        .then((rooms) {
          myRoomsList = RoomModel.fromList(rooms);
          emit(BLERefreshUI());
        })
        .catchError((e) {
          emit(
            DBTransiactionErrorState('Error loading rooms: ${e.toString()}'),
          );
        });
  }

  List<DeviceModel> myDevices = [];
  void getAllDevices() async {
    await DBHelper.getAllDevices()
        .then((devices) {
          myDevices = DeviceModel.fromList(devices);
          emit(BLERefreshUI());
        })
        .catchError((e) {
          emit(
            DBTransiactionErrorState('Error loading devices: ${e.toString()}'),
          );
        });
  }

  void setState() {
    emit(BLERefreshUI());
  }

  /// ble
  StreamSubscription<BluetoothConnectionState>? _connectionStream;

  bool selectedLanguage = true;
  BluetoothCharacteristic? selectedCharacteristic;
  BluetoothDevice? connectedDevice;
  List<BluetoothService> services = [];
  final List<BluetoothDevice> devicesList = <BluetoothDevice>[];
  final Map<Guid, List<int>> readValues = <Guid, List<int>>{};
  void findDeviceByUnitId(String unitId) async {
    try {
      final allDevices = await DBHelper.getAllDevices();
      final matchedDevice = allDevices.firstWhere(
        (device) => device['device_unit_id'] == unitId,
        orElse: () => {},
      );

      if (matchedDevice.isNotEmpty) {
        emit(BleDeviceFound(device: matchedDevice));
      } else {
        emit(BleDeviceNotFound(unitId: unitId));
      }
    } catch (e) {
      emit(BleError(err: "Error searching device: ${e.toString()}"));
    }
  }

  addDeviceTolist(final BluetoothDevice device) {
    if (!devicesList.contains(device)) {
      if (device.advName.isNotEmpty && device.advName.startsWith("LM:")) {
        devicesList.add(device);
      }
    }
  }

  initBluetooth(BuildContext context) async {
    emit(BleScanning());

    if (await PermissionBLE.requestPermissions()) {
      final isCurrentlyScanning = await FlutterBluePlus.isScanning.first;
      if (isCurrentlyScanning) {
        await FlutterBluePlus.stopScan();
      }

      var subscription = FlutterBluePlus.onScanResults.listen(
        (results) {
          if (results.isNotEmpty) {
            for (ScanResult result in results) {
              addDeviceTolist(result.device);
            }
            emit(BleAddDevice());
          }
        },
        onError: (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Scan Error: ${e.toString()}")),
          );
          emit(BleScanningError(err: e.toString()));
          print(e.toString());
        },
      );

      FlutterBluePlus.cancelWhenScanComplete(subscription);

      await FlutterBluePlus.adapterState
          .where((val) => val == BluetoothAdapterState.on)
          .first;

      try {
        await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
      } catch (e) {
        emit(BleScanningError(err: "Scan failed: $e"));
        print(e.toString());
        return;
      }

      await FlutterBluePlus.isScanning.where((val) => val == false).first;

      final connected = FlutterBluePlus.connectedDevices;
      for (var device in connected) {
        addDeviceTolist(device);
      }
    } else {
      emit(BleScanningError(err: 'Permission must be accepted'));
      print('Permission must be accepted');
    }
  }

  String idTryConnected = '';
  Future<void> connect(
    BluetoothDevice device,
    String pass,
    String nickname,
  ) async {
    await FlutterBluePlus.stopScan();
    idTryConnected = device.advName;
    emit(BleTryConnect());
    try {
      BluetoothConnectionState currentState =
          await device.connectionState.first;
      if (currentState == BluetoothConnectionState.connected ||
          currentState == BluetoothConnectionState.connecting) {
        await device.disconnect(); // ينظف الاتصال المعلق
        await Future.delayed(
          Duration(milliseconds: 500),
        ); // تأخير بسيط لتجنب Error 133
      }

      await device.connect();
    } on PlatformException catch (e) {
      if (e.code != 'already_connected') {
        emit(BleError(err: "Connect failed: ${e.message}"));
        return;
      }
    } catch (e) {
      emit(BleError(err: "Connection failed: ${e.toString()}"));
      return;
    }

    try {
      services = await device.discoverServices();
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic c in service.characteristics) {
          if (c.properties.write) {
            selectedCharacteristic = c;
            break;
          }
        }
      }

      connectedDevice = device;
      emit(BleConnected());
      String credit =
          'wifi:${wifiSsid}|pass:${pass}|home:${AppSession.overview.first.home.id}|room:${selectedRoomServerId}|name:${nickname}';
      writeToSelectedCharacteristic(credit);
      print(credit);
      findDeviceByUnitId(device.advName);
      await _connectionStream?.cancel();

      _connectionStream = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.connected) {
          connectedIcon = Icons.bluetooth_audio_sharp;
          isConnected = true;
          emit(BleConnected());
        } else if (state == BluetoothConnectionState.disconnected) {
          _handleDisconnection();
        }
      });
    } catch (e) {
      emit(BleError(err: "Service discovery failed: ${e.toString()}"));
      await device.disconnect();
    }
  }

  StreamSubscription<List<int>>? _valueSubscription;

  @override
  Future<void> close() {
    _connectionStream?.cancel();
    _valueSubscription?.cancel();
    return super.close();
  }

  String wifiSsid = '';
  void getSSid() async {
    final info = NetworkInfo();
    String wifiSsidWithDot = await info.getWifiName() ?? '"No Internet"';
    wifiSsid = wifiSsidWithDot.replaceAll('"', '');
    emit(BLERefreshUI());
  }

  // Updated write method
  Future<void> writeToSelectedCharacteristic(String data) async {
    if (selectedCharacteristic == null || connectedDevice == null) {
      emit(BleWriteError(err: "Not connected to device"));
      return;
    }

    try {
      final bytes = utf8.encode(data);
      final mtu = await connectedDevice!.mtu.first;
      final chunkSize = mtu - 3;

      for (int i = 0; i < bytes.length; i += chunkSize) {
        final end = (i + chunkSize).clamp(0, bytes.length);
        await selectedCharacteristic!.write(
          bytes.sublist(i, end),
          withoutResponse:
              selectedCharacteristic!.properties.writeWithoutResponse,
        );
      }

      emit(BleWriteSuccess());
      disconnect();
    } on PlatformException catch (e) {
      emit(BleWriteError(err: "Write failed: ${e.message}"));
      _handleDisconnection();
    }
  }

  // New helper method
  void _handleDisconnection() {
    _connectionStream?.cancel();
    _valueSubscription?.cancel();
    connectedDevice = null;
    selectedCharacteristic = null;
    connectedIcon = Icons.bluetooth_disabled_sharp;
    isConnected = false;
    emit(BleDisconnected());
  }

  Future<void> disconnect() async {
    if (connectedDevice == null) {
      emit(BleError(err: "No device is currently connected"));
      return;
    }

    try {
      if (_connectionStream != null) {
        await _connectionStream!.cancel();
        _connectionStream = null;
      }

      if (_valueSubscription != null) {
        await _valueSubscription!.cancel();
        _valueSubscription = null;
      }

      BluetoothConnectionState state =
          await connectedDevice!.connectionState.first;
      if (state == BluetoothConnectionState.connected) {
        await connectedDevice!.disconnect();
      }

      connectedDevice = null;
      selectedCharacteristic = null;
      services.clear();
      isConnected = false;
      connectedIcon = Icons.bluetooth_disabled;

      emit(BleDisconnected());
    } on PlatformException catch (e) {
      emit(BleError(err: "Platform error during disconnect: ${e.message}"));
      print("Platform error during disconnect: ${e.message}");
    } catch (e) {
      emit(
        BleError(err: "Unexpected error during disconnect: ${e.toString()}"),
      );
      print("Unexpected error during disconnect: ${e.toString()}");
    }
  }

  List<DeviceModel> mydevices = [];
  void getRoomDevices(int id) {
    emit(LoadingRoomDevices());
    print('*** the ROOM : $id');

    mydevices = [];
    DBHelper.getDevicesForRoom(id)
        .then((value) {
          mydevices = DeviceModel.fromList(value);
          print(mydevices);
          for (var d in mydevices) {
            print('***');
            print(d.name);
            print(d.device_type);
            print(d.iconPath);
            print(d.device_unit_id);
            print(d.id);
            print(d.serverId);
            print(d.nickname);
            print('***');
          }
          emit(GetRoomDevices());
        })
        .catchError((err) {
          emit(ErrorRoomDevices(err: err.toString()));
        });
  }

  Future<void> refreshHome() {
    emit(RefreshHomeLoading());

    return DioHelper.get<Map<String, dynamic>>(profile_route, auth: true)
        .then((res) async {
          print('PROFILE STATUS: ${res.statusCode}');
          print('PROFILE DATA  : ${res.data}');

          final data = res.data!;
          final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
          final overview =
              (data['overview'] as List? ?? [])
                  .map((e) => HomeOverview.fromJson(e as Map<String, dynamic>))
                  .toList();

          await DBHelper.upsertUser(
            serverId: user.id,
            email: user.email,
            name: user.name,
            mobile: user.mobile,
          );

          await DBHelper.syncFromOverview(overview);

          getAllRooms();
          getAllDevices();

          AppSession.currentUser = user;
          AppSession.overview = overview;

          await CacheHelper.saveUser(user.toJson());
          await CacheHelper.saveOverview(
            overview.map((e) => e.toJson()).toList(),
          );

          emit(RefreshHomeSuccess(user: user, overview: overview));
        })
        .catchError((e) {
          if (e is DioException) {
            final code = e.response?.statusCode;
            final body = e.response?.data;
            print('PROFILE ERROR: HTTP $code -> $body');
            emit(
              RefreshHomeError(
                message: 'HTTP $code',
                statusCode: code,
                body: body,
              ),
            );
          } else {
            print('PROFILE ERROR: $e');
            emit(RefreshHomeError(message: e.toString()));
          }
        });
  }
}
