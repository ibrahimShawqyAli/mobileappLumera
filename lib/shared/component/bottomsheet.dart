import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_iotz/shared/component/inputComponent.dart';
import 'package:smart_home_iotz/shared/component/presentationComponent.dart';
import 'package:smart_home_iotz/shared/cubit/main_cubit.dart';
import 'package:smart_home_iotz/shared/cubit/main_state.dart';
import 'package:smart_home_iotz/shared/style/appColors.dart';

Future addRoomSheet(BuildContext context) => showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  clipBehavior: Clip.antiAlias,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
  ),
  builder: (context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;
    final TextEditingController nameController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final List<String> roomIcons = [
      'assets/images/christopher-jolly-GqbU78bdJFM-unsplash.jpg',
      'assets/images/francesca-tosolini-qnSTxcs0EEs-unsplash.jpg', // dining room
      'assets/images/spacejoy-umAXneH4GhA-unsplash.jpg', // living room
      'assets/images/raquel-navalon-alvarez-TWj0qbJn4zI-unsplash.jpg', // bathroom
      // bedroom
      'assets/images/jason-briscoe-GliaHAJ3_5A-unsplash.jpg', // kitchen
      'assets/images/luca-bravo-9l_326FISzk-unsplash.jpg', // workspace / desk
      'assets/images/samuel-girven-VJ2s0c20qCo-unsplash.jpg', // wine cellar / gym
      'assets/images/point3d-commercial-imaging-ltd-iPYwrj2CZxE-unsplash.jpg', // laundry / utility room
      'assets/images/slava-keyzman-ZG4Y6lLPARw-unsplash.jpg', // office / studio
      'assets/images/jon-tyson-kGUmNEYaSMY-unsplash.jpg',
      'assets/images/ignacio-correia-1_yycyoMT6g-unsplash.jpg', // garden / path
    ];
    int selected = 0;

    return Material(
      color: Appcolors.myBK(theme),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          width: w,
          height: h * 0.5,
          decoration: BoxDecoration(color: Appcolors.myBK(theme)),
          child: BlocConsumer<BleCubit, BleState>(
            listener: (context, state) {
              if (state is DBTransiactionState) {
                Navigator.pop(context);
                showToast('Saved ${state.msg}');
              } else if (state is DBTransiactionErrorState) {
                showToast('Error ${state.msg}');
              }
            },
            builder: (context, state) {
              return Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          'Add Rooms',
                          style: mystyle(size: 18, isBold: true),
                        ),
                        const SizedBox(height: 10),
                        inputText(
                          context,
                          controller: nameController,
                          hintText: 'Room Name',
                          validate: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter the Room Name';
                            }
                            return null;
                          },
                          prefixIcon: Icon(Icons.home, color: Appcolors.grey),
                          suffixIcon: IconButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                BleCubit.get(context).addRoom(
                                  name: nameController.text.trim(),
                                  path: roomIcons[selected],
                                  is_private: false,
                                );
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
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: (w / 75).floor(),
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                            itemCount: roomIcons.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder:
                                (context, index) => InkWell(
                                  onTap: () {
                                    selected = index;
                                    BleCubit.get(context).setState();
                                  },
                                  child: Container(
                                    width: 70,
                                    height: 70,
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
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  },
);
