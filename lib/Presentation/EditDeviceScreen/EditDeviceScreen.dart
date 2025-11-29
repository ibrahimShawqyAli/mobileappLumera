import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_iotz/Presentation/Setting/setting.dart';
import 'package:smart_home_iotz/Presentation/drawer/drawer.dart';
import 'package:smart_home_iotz/Presentation/home/homeScreen.dart';
import 'package:smart_home_iotz/shared/component/inputComponent.dart';
import 'package:smart_home_iotz/shared/component/list.dart';
import 'package:smart_home_iotz/shared/component/logic.dart';
import 'package:smart_home_iotz/shared/component/presentationComponent.dart';
import 'package:smart_home_iotz/shared/cubit/main_cubit.dart';
import 'package:smart_home_iotz/shared/cubit/main_state.dart';
import 'package:smart_home_iotz/shared/style/appColors.dart';

class EditDeviceScreen extends StatefulWidget {
  const EditDeviceScreen({super.key, required this.deviceId});
  final int deviceId;
  @override
  State<EditDeviceScreen> createState() => _EditDeviceScreenState();
}

class _EditDeviceScreenState extends State<EditDeviceScreen> {
  final TextEditingController name_controller = TextEditingController();
  final TextEditingController type_controller = TextEditingController();
  final GlobalKey<FormState> form_key = GlobalKey<FormState>();

  int selected = 0;
  List<String> options = [
    'On-Off',
    'RGB',
    'Smart Fan',
    'Temperature Sensor',
    'Motion Detector',
    'Smart Plug',
    'Car Charger',
  ];
  int tag_type = 0; // Default selected
  int tag_room_id = 0;
  final List<String> deviceIcons = [
    'assets/images/lights.png',
    'assets/images/vehicle.png',
    'assets/images/water-heater.png',
    'assets/images/door-handle.png',
    'assets/images/fan.png',
    'assets/images/oven.png',
    'assets/images/air-conditioner.png',
    'assets/images/drainage.png',
  ];
  @override
  void initState() {
    super.initState();

    final cubit = BleCubit.get(context);
    final device = cubit.myDevices.firstWhere((d) => d.id == widget.deviceId);

    // Pre-fill fields
    name_controller.text = device.name;
    tag_type = options.indexOf(device.device_type); // set index from options
    selected = deviceIcons.indexOf(device.iconPath); // find icon index
    tag_room_id = cubit.myRoomsList.indexWhere(
      (room) => room.id == device.roomId,
    );
    if (tag_room_id == -1) tag_room_id = 0; // fallback
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final GlobalKey<ScaffoldState> keyState = GlobalKey<ScaffoldState>();
    List<String> roomNames =
        BleCubit.get(context).myRoomsList.map((room) => room.name).toList();
    List<int> roomId =
        BleCubit.get(context).myRoomsList.map((room) => room.id).toList();
    return Scaffold(
      key: keyState,
      backgroundColor: Appcolors.myBK(theme),
      endDrawer: myDrawer(context),
      body: SafeArea(
        child: BlocConsumer<BleCubit, BleState>(
          listener: (context, state) {
            if (state is DBTransiactionState) {
              showToast('Saved ${state.msg}');
              Navigator.pushReplacement(
                context,
                NavigateWithAnimation(child: Homescreen(), isRight: true),
              );
            } else if (state is DBTransiactionErrorState) {
              showToast('Error ${state.msg}');
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Form(
                key: form_key,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                NavigateWithAnimation(
                                  child: Homescreen(),
                                  isRight: true,
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: Appcolors.grey,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed:
                                () => BleCubit.get(context).getAllDevices(),
                            icon: Icon(Icons.refresh, color: Appcolors.grey),
                          ),
                          IconButton(
                            onPressed: () {
                              keyState.currentState!.openEndDrawer();
                            },
                            icon: Icon(Icons.menu, color: Appcolors.grey),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Edit Devices', style: mystyle(size: 24)),
                      ),

                      const SizedBox(height: 10),
                      inputText(
                        context,
                        controller: name_controller,
                        hintText: 'Device Name',
                        validate:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Please Enter the Name'
                                    : null,
                        prefixIcon: Icon(Icons.code, color: Appcolors.grey),
                        suffixIcon: IconButton(
                          onPressed: () {
                            if (form_key.currentState!.validate()) {
                              BleCubit.get(context).editDevice(
                                name: name_controller.text.trim(),
                                id: widget.deviceId,
                                type: options[tag_type],
                                iconPath: deviceIcons[selected],
                                roomId: roomId[tag_room_id],
                              );
                            }
                          },
                          icon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Save', style: mystyle(size: 16)),
                              Icon(Icons.save, color: Appcolors.grey),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ChipsChoice<int>.single(
                        value: tag_type,
                        onChanged: (val) => setState(() => tag_type = val),
                        choiceItems: C2Choice.listFrom<int, String>(
                          source: options,
                          value: (i, v) => i,
                          label: (i, v) => v,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ChipsChoice<int>.single(
                          value: tag_room_id,
                          onChanged: (val) => setState(() => tag_room_id = val),
                          choiceItems: C2Choice.listFrom<int, String>(
                            source: roomNames,
                            value: (i, v) => i,
                            label: (i, v) => v,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ConstrainedBox(
                        constraints: BoxConstraints(minHeight: 100),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: (w / 75).floor(),
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemCount: deviceIcons.length,
                          itemBuilder:
                              (context, index) => InkWell(
                                onTap: () => setState(() => selected = index),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black,
                                    border: Border.all(
                                      color:
                                          selected == index
                                              ? Color(0xffE684AE)
                                              : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Image.asset(
                                      deviceIcons[index],
                                      fit: BoxFit.cover,
                                      width: 70,
                                      height: 70,
                                    ),
                                  ),
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      condition(
                        context,
                        cond: BleCubit.get(context).myRoomsList.isNotEmpty,
                        child: deviceList(
                          BleCubit.get(context).myDevices,
                          BleCubit.get(context).myRoomsList,
                        ),
                        fall: Text('No Saved Device', style: mystyle(size: 18)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
