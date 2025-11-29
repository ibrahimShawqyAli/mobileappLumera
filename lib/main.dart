// lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smart_home_iotz/Presentation/get Started/getstarted.dart';
import 'package:smart_home_iotz/Presentation/home/homeScreen.dart';

import 'package:smart_home_iotz/shared/Cache/cacheHelper.dart';
import 'package:smart_home_iotz/shared/DB/db.dart';
import 'package:smart_home_iotz/shared/Remote/dioHelper.dart';
import 'package:smart_home_iotz/shared/bloc/bloc_obs.dart';
import 'package:smart_home_iotz/shared/cubit/main/main_cubit.dart';
import 'package:smart_home_iotz/shared/cubit/main_cubit.dart'; // <- keep one import
import 'package:smart_home_iotz/shared/cubit/startupCubit.dart';
import 'package:smart_home_iotz/shared/session/session.dart';
import 'package:smart_home_iotz/shared/style/appColors.dart';
import 'package:smart_home_iotz/shared/variables/variables.dart';
import 'package:smart_home_iotz/shared/web/hub.dart';
import 'package:smart_home_iotz/shared/web/socket.dart';

/// Make sure your WS URL is EXACT (no http://, no trailing #)
/// Example:
/// const myWebSocketServer = 'ws://192.168.1.108:8080/ws/app';
void main() {
  // If you want zone errors to be fatal in debug:
  // BindingBase.debugZoneErrorsAreFatal = true;

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized(); // <-- in same zone as runApp

      // Route Flutter framework errors to this zone
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        Zone.current.handleUncaughtError(details.exception, details.stack!);
      };

      Bloc.observer = MyBlocObserver();

      // Init local services (DB, cache)
      await DBHelper.database;
      await CacheHelper.init();

      // Tokens
      token = (CacheHelper.getAccessToken() ?? CacheHelper.getToken() ?? '');
      final isLoggedIn = token.isNotEmpty;

      // Network stack
      await AppSession.bootstrap();
      DioHelper.init();

      try {
        await SocketHub.init(myWebSocketServer);
      } catch (e, st) {
        debugPrint('SocketHub.init error: $e');
        debugPrint(st.toString());
      }

      // Optional: first-frame marker
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('✅ First frame rendered');
      });

      runApp(MainApp(isLoggedIn: isLoggedIn)); // <-- same zone
    },
    (error, stack) {
      debugPrint('Uncaught ► $error');
      debugPrint(stack.toString());
    },
  );
}

class MainApp extends StatelessWidget {
  final bool isLoggedIn;
  const MainApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (_) =>
                  BleCubit()
                    ..getAllRooms()
                    ..getAllDevices(),
        ),
        BlocProvider(create: (_) => StartupCubit()..initTimer()),
        BlocProvider(create: (_) => MainCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Appcolors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.black,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              foregroundColor: WidgetStatePropertyAll(Colors.white),
              backgroundColor: WidgetStatePropertyAll(Colors.teal),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
          ),
        ),
        home: isLoggedIn ? Homescreen() : const GetStarted(),
      ),
    );
  }
}
