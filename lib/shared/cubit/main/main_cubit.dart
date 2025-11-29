import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_iotz/Models/deviceModel/deviceModel.dart';
import 'package:smart_home_iotz/shared/DB/db.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit() : super(MainInitial());
  static MainCubit get(context) => BlocProvider.of(context);

  List<DeviceModel> mydevices = [];
  void getRoomDevices(int id) {
    emit(LoadingRoomDevices());
    mydevices = [];
    DBHelper.getDevicesForRoom(id)
        .then((value) {
          mydevices = DeviceModel.fromList(value);
          emit(GetRoomDevices());
        })
        .catchError((err) {
          emit(ErrorRoomDevices(err: err.toString()));
        });
  }
}
