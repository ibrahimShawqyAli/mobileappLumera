import 'package:smart_home_iotz/Models/homeModel/home_overview.dart';
import 'package:smart_home_iotz/Models/userModel/userModel.dart';

abstract class BleState {}

class BleInitial extends BleState {}

class BleScanning extends BleState {}

class BleAddDevice extends BleState {}

class BleConnected extends BleState {}

class BleScanningError extends BleState {
  final String err;
  BleScanningError({required this.err});
}

class BleWriteError extends BleState {
  final String err;
  BleWriteError({required this.err});
}

class BleWriteSuccess extends BleState {}

class BleDisconnected extends BleState {}

class BleError extends BleState {
  final String err;

  BleError({required this.err});
}

class BleRotated extends BleState {}

class BlePickingColor extends BleState {}

class BLERefreshUI extends BleState {}

class BLETimerRefresh extends BleState {}

class DBTransiactionState extends BleState {
  final String msg;
  DBTransiactionState(this.msg);
}

class DBTransiactionErrorState extends BleState {
  final String msg;
  DBTransiactionErrorState(this.msg);
}

class BleDeviceFound extends BleState {
  final Map<String, dynamic> device;
  BleDeviceFound({required this.device});
}

class BleDeviceNotFound extends BleState {
  final String unitId;
  BleDeviceNotFound({required this.unitId});
}

class BleTryConnect extends BleState {}

final class LoadingRoomDevices extends BleState {}

final class GetRoomDevices extends BleState {}

final class ErrorRoomDevices extends BleState {
  final String err;

  ErrorRoomDevices({required this.err});
}

class RefreshHomeLoading extends BleState {}

class RefreshHomeSuccess extends BleState {
  final UserModel user;
  final List<HomeOverview> overview;
  RefreshHomeSuccess({required this.user, required this.overview});
}

class RefreshHomeError extends BleState {
  final String message;
  final int? statusCode;
  final dynamic body;
  RefreshHomeError({required this.message, this.statusCode, this.body});
}

class ServerAddRoom extends BleState {}

class ServerAddRoomError extends BleState {
  final String err;
  ServerAddRoomError({required this.err});
}

class ServerEditRoom extends BleState {}

class ServerEditRoomError extends BleState {
  final String err;
  ServerEditRoomError({required this.err});
}

class LoadingMembersState extends BleState {}

class LoadedMembersState extends BleState {}

class ErrorMembersState extends BleState {
  final String err;
  ErrorMembersState(this.err);
}

class AddingMemberState extends BleState {}

class AddedMemberState extends BleState {}

class ErrorAddingMemberState extends BleState {
  final String err;
  ErrorAddingMemberState(this.err);
}
