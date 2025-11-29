import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_iotz/Presentation/Setting/setting.dart';
import 'package:smart_home_iotz/Presentation/drawer/drawer.dart';
import 'package:smart_home_iotz/shared/component/inputComponent.dart';
import 'package:smart_home_iotz/shared/component/list.dart';
import 'package:smart_home_iotz/shared/component/logic.dart';
import 'package:smart_home_iotz/shared/component/presentationComponent.dart';
import 'package:smart_home_iotz/shared/cubit/main_cubit.dart';
import 'package:smart_home_iotz/shared/cubit/main_state.dart';
import 'package:smart_home_iotz/shared/style/appColors.dart';

class AddRoomScreen extends StatefulWidget {
  final creation_of_room;
  final serverID;
  final name;
  const AddRoomScreen({
    super.key,
    this.creation_of_room = true,
    this.serverID,
    this.name = "",
  });

  @override
  State<AddRoomScreen> createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  final TextEditingController name_controller = TextEditingController();
  final GlobalKey<FormState> form_key = GlobalKey<FormState>();
  int selected = 0;

  final List<String> roomIcons = [
    'assets/images/christopher-jolly-GqbU78bdJFM-unsplash.jpg',
    'assets/images/francesca-tosolini-qnSTxcs0EEs-unsplash.jpg',
    'assets/images/spacejoy-umAXneH4GhA-unsplash.jpg',
    'assets/images/raquel-navalon-alvarez-TWj0qbJn4zI-unsplash.jpg',
    'assets/images/jason-briscoe-GliaHAJ3_5A-unsplash.jpg',
    'assets/images/luca-bravo-9l_326FISzk-unsplash.jpg',
    'assets/images/samuel-girven-VJ2s0c20qCo-unsplash.jpg',
    'assets/images/point3d-commercial-imaging-ltd-iPYwrj2CZxE-unsplash.jpg',
    'assets/images/slava-keyzman-ZG4Y6lLPARw-unsplash.jpg',
    'assets/images/jon-tyson-kGUmNEYaSMY-unsplash.jpg',
    'assets/images/ignacio-correia-1_yycyoMT6g-unsplash.jpg',
  ];
  @override
  void initState() {
    super.initState();
    name_controller.text = widget.name;
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final GlobalKey<ScaffoldState> keyState = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: keyState,
      backgroundColor: Appcolors.myBK(theme),
      endDrawer: myDrawer(context),
      body: SafeArea(
        child: BlocConsumer<BleCubit, BleState>(
          listener: (context, state) {
            if (state is ServerAddRoom) {
              showToast('Saved to Server');
            } else if (state is ServerAddRoomError) {
              showToast('Error ${state.err}');
            }
            if (state is ServerEditRoom) {
              showToast('Saved to Server');
              Navigator.pop(context);
            } else if (state is ServerEditRoomError) {
              showToast('Error ${state.err}');
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
                                  child: Setting(),
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
                                () => BleCubit.get(context).getAllRooms(),
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
                        child: Text(
                          widget.creation_of_room ? 'Add Rooms' : 'Edit Rooms',
                          style: mystyle(size: 24),
                        ),
                      ),
                      const SizedBox(height: 10),
                      inputText(
                        context,
                        controller: name_controller,
                        hintText: 'Room Name',
                        validate:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Please Enter the Room Name'
                                    : null,
                        prefixIcon: Icon(Icons.home, color: Appcolors.grey),
                        suffixIcon: IconButton(
                          onPressed: () {
                            if (form_key.currentState!.validate()) {
                              if (widget.creation_of_room == true) {
                                BleCubit.get(context).addRoom(
                                  name: name_controller.text.trim(),
                                  path: roomIcons[selected],
                                  is_private: false,
                                );
                              } else {
                                BleCubit.get(context).editRoom(
                                  id: widget.serverID,
                                  name: name_controller.text.trim(),
                                  path: roomIcons[selected],
                                  is_private: false,
                                );
                              }
                              FocusScope.of(context).unfocus();
                            }
                          },
                          icon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.save, color: Appcolors.grey),
                              Text('Save', style: mystyle(size: 14)),
                              const SizedBox(width: 15),
                            ],
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
                          itemCount: roomIcons.length,
                          itemBuilder:
                              (context, index) => InkWell(
                                onTap: () => setState(() => selected = index),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          selected == index
                                              ? Color(0xffE684AE)
                                              : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      roomIcons[index],
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
                        child: roomList(BleCubit.get(context).myRoomsList),
                        fall: Text('No Saved Rooms', style: mystyle(size: 18)),
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
