import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_iotz/Presentation/Setting/setting.dart';

import 'package:smart_home_iotz/shared/component/inputComponent.dart';
import 'package:smart_home_iotz/shared/component/list.dart';
import 'package:smart_home_iotz/shared/component/logic.dart';
import 'package:smart_home_iotz/shared/component/presentationComponent.dart';
import 'package:smart_home_iotz/shared/cubit/main_cubit.dart';
import 'package:smart_home_iotz/shared/cubit/main_state.dart';
import 'package:smart_home_iotz/shared/style/appColors.dart';

class Pairingscreen extends StatefulWidget {
  Pairingscreen({super.key});

  @override
  State<Pairingscreen> createState() => _PairingscreenState();
}

class _PairingscreenState extends State<Pairingscreen> {
  final TextEditingController _password_Controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    _password_Controller.addListener(() {
      setState(() {}); // Trigger rebuild when password changes
    });
  }

  @override
  Widget build(BuildContext context) {
    var cubit = BleCubit.get(context);

    return Scaffold(
      backgroundColor: Appcolors.myBK(theme),
      body: Center(
        child: BlocConsumer<BleCubit, BleState>(
          listener: (context, state) {},
          builder: (context, state) {
            return SafeArea(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              NavigateWithAnimation(
                                child: Setting(),
                                isRight: true,
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: Appcolors.grey,
                            size: 25,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            cubit.initBluetooth(context);
                          },
                          child: Text('Pairing', style: mystyle(size: 16)),
                        ),
                      ],
                    ),
                  ),
                  Text('Connected Wifi:${cubit.wifiSsid}'),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: inputText(
                      context,
                      controller: _password_Controller,
                      hintText: 'Wifi Password',
                      suffixIcon: Icon(
                        Icons.lock,
                        size: 30,
                        color: Appcolors.grey,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 0,
                      bottom: 20,
                      right: 10,
                      left: 10,
                    ),
                    child: myRoomDropMenu(context),
                  ),
                  condition(
                    context,
                    cond: state is! BleScanning,
                    fall: Center(child: CircularProgressIndicator()),
                    child: condition(
                      context,
                      cond: cubit.devicesList.isNotEmpty,
                      child: deviceListBLE(
                        context,
                        devicesList: cubit.devicesList,
                        color: Appcolors.grey,
                        pass: _password_Controller.text.trim(),
                      ),
                      fall: Text('No Device', style: mystyle(size: 18)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
