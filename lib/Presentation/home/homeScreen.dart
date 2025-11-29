import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:smart_home_iotz/Presentation/drawer/drawer.dart';
import 'package:smart_home_iotz/layout/pageMove.dart';
import 'package:smart_home_iotz/shared/component/presentationComponent.dart';
import 'package:smart_home_iotz/shared/cubit/main_cubit.dart';
import 'package:smart_home_iotz/shared/cubit/main_state.dart';
import 'package:smart_home_iotz/shared/session/session.dart';
import 'package:smart_home_iotz/shared/style/appColors.dart';
import 'package:smart_home_iotz/shared/variables/variables.dart';

class Homescreen extends StatefulWidget {
  Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _keyState = GlobalKey<ScaffoldState>();
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);

    _shakeAnimation = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );

    // Stop animation after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      _shakeController.stop();
      _shakeController.reset();
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Appcolors.statusColor,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    //
    DateTime now = DateTime.now();
    String formatted = DateFormat('EEEE, d, MMM').format(now);
    return Scaffold(
      backgroundColor: Appcolors.myBK(theme),
      key: _keyState,
      endDrawer: myDrawer(context),
      body: BlocConsumer<BleCubit, BleState>(
        listener: (context, state) {
          if (state is RefreshHomeSuccess) {
            showToast("Refresh Profile");
          }
          if (state is RefreshHomeError) {
            showToast(state.message);
          }
          if (state is BleWriteError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.err),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child: Skeletonizer(
                enabled: state is RefreshHomeLoading,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (AppSession.currentUser?.name
                                            ?.trim()
                                            .isNotEmpty ??
                                        false)
                                    ? AppSession.currentUser!.name!
                                    : AppSession.currentUser?.email
                                            .split('@')
                                            .first ??
                                        'Guest',
                                style: mystyle(size: 22),
                              ),
                              Text(formatted, style: mystyle(size: 16)),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              BleCubit.get(context).refreshHome();
                            },
                            icon: Icon(
                              Icons.refresh,
                              color: Appcolors.grey,
                              size: 30,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _keyState.currentState!.openEndDrawer();
                            },
                            icon: Icon(
                              Icons.menu,
                              color: Appcolors.grey,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: PageMove()),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
