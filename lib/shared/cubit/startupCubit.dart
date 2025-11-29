import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_iotz/Models/userModel/auth_model.dart';
import 'package:smart_home_iotz/shared/Cache/cacheHelper.dart';
import 'package:smart_home_iotz/shared/DB/db.dart';
import 'package:smart_home_iotz/shared/Remote/dioHelper.dart';
import 'package:smart_home_iotz/shared/cubit/startupState.dart';
import 'package:smart_home_iotz/shared/session/session.dart';
import 'package:smart_home_iotz/shared/variables/variables.dart';

class StartupCubit extends Cubit<StartupState> {
  StartupCubit() : super(StartupInit());
  static StartupCubit get(BuildContext context) => BlocProvider.of(context);
  //
  int animationIndex = 0;
  //
  Timer? _timer;
  bool isDone = false;
  void initTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 400), (_) async {
      if (animationIndex > 10) {
        stopTimer();
        emit(StartupAnimationUpdate());
      } else {
        if (isDone == false) {
          animationIndex++;
          emit(StartupAnimationUpdate());
        } else {}
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  Future<void> login({required String email, required String password}) async {
    emit(LoginLoading());

    try {
      final Response<Map<String, dynamic>>
      res = await DioHelper.post<Map<String, dynamic>>(
            login_route,
            auth: false,
            data: {'email': email.trim(), 'password': password},
          )
          .then((value) async {
            print('LOGIN STATUS: ${value.statusCode}');
            print('LOGIN DATA  : ${value.data}');

            final auth = AuthResponse.fromJson(value.data!);

            token = auth.access;
            AppSession.hydrateFromAuth(auth);
            await CacheHelper.saveData(key: 'access_token', value: auth.access);
            await CacheHelper.saveData(
              key: 'refresh_token',
              value: auth.refresh,
            );
            await CacheHelper.saveData(key: 'user', value: auth.user.toJson());
            await CacheHelper.saveData(
              key: 'overview',
              value: auth.overview.map((e) => e.toJson()).toList(),
            );
            await DBHelper.upsertUser(
              serverId: auth.user.id,
              email: auth.user.email,
              name: auth.user.name,
              mobile: auth.user.mobile,
            );

            await DBHelper.syncFromOverview(auth.overview);

            return value;
          })
          .catchError((e) {
            if (e is DioException) {
              final code = e.response?.statusCode;
              final body = e.response?.data;
              print('LOGIN ERROR  : HTTP $code -> $body');
            } else {
              print('LOGIN ERROR  : $e');
            }
            throw e;
          });

      emit(LoginSuccess());
    } on DioException catch (e) {
      final msg =
          (e.response?.data is Map)
              ? (e.response?.data['message'] ??
                      e.response?.data['error'] ??
                      e.response?.data)
                  .toString()
              : (e.message ?? 'Request failed');
      emit(LoginError(error: 'HTTP ${e.response?.statusCode}: $msg'));
    } catch (e) {
      emit(LoginError(error: e.toString()));
    }
  }
}
