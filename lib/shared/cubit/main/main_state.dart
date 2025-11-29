part of 'main_cubit.dart';

sealed class MainState extends Equatable {
  const MainState();

  @override
  List<Object> get props => [];
}

final class MainInitial extends MainState {}

final class LoadingRoomDevices extends MainState {}

final class GetRoomDevices extends MainState {}

final class ErrorRoomDevices extends MainState {
  final String err;

  const ErrorRoomDevices({required this.err});
}
