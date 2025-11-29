import 'package:chips_choice/chips_choice.dart';
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
import 'package:smart_home_iotz/shared/session/session.dart';
import 'package:smart_home_iotz/shared/style/appColors.dart';

class AddMember extends StatefulWidget {
  const AddMember({super.key});

  @override
  State<AddMember> createState() => _AddMemberState();
}

class _AddMemberState extends State<AddMember> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // roles
  final List<String> roleOptions = ['owner', 'admin', 'member', 'guest'];
  int tagRole = 2; // default 'member'

  List<int> selectedRoomIndexes = [];
  bool _roomsInitDone = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = BleCubit.get(context);
    final rooms = cubit.myRoomsList;
    final List<String> roomNames = rooms.map((room) => room.name).toList();
    final List<int> roomServerIds = rooms.map((room) => room.serverId).toList();

    if (!_roomsInitDone && roomNames.isNotEmpty) {
      selectedRoomIndexes = List<int>.generate(
        roomNames.length,
        (index) => index,
      );
      _roomsInitDone = true;
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Appcolors.myBK(theme),
      endDrawer: myDrawer(context),
      body: SafeArea(
        child: BlocConsumer<BleCubit, BleState>(
          listener: (context, state) {
            if (state is DBTransiactionState) {
              showToast('Saved ${state.msg}');
            } else if (state is DBTransiactionErrorState) {
              showToast('Error ${state.msg}');
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Form(
                key: formKey,
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
                            onPressed: () {
                              cubit.getMembers(
                                AppSession.overview.first.home.id,
                              );
                            },
                            icon: Icon(Icons.refresh, color: Appcolors.grey),
                          ),
                          IconButton(
                            onPressed: () {
                              _scaffoldKey.currentState?.openEndDrawer();
                            },
                            icon: Icon(Icons.menu, color: Appcolors.grey),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Add Member', style: mystyle(size: 24)),
                      ),
                      const SizedBox(height: 10),

                      // Name
                      inputText(
                        context,
                        controller: nameController,
                        hintText: 'Name',
                        validate:
                            (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Please enter the name'
                                    : null,
                        prefixIcon: Icon(Icons.person, color: Appcolors.grey),
                      ),
                      const SizedBox(height: 10),

                      // Password
                      inputText(
                        context,
                        keybaord: TextInputType.emailAddress,
                        controller: emailController,
                        hintText: 'Email',
                        validate:
                            (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Please enter the email'
                                    : null,
                        prefixIcon: Icon(Icons.email, color: Appcolors.grey),
                      ),
                      const SizedBox(height: 10),

                      // Email + Save button
                      inputText(
                        context,
                        controller: passwordController,
                        hintText: 'Password',

                        validate:
                            (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Please enter the password'
                                    : null,

                        prefixIcon: Icon(Icons.lock, color: Appcolors.grey),
                      ),
                      const SizedBox(height: 10),
                      inputText(
                        context,
                        keybaord: TextInputType.phone,
                        controller: mobileController,
                        hintText: 'Mobile',
                        validate:
                            (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Please enter the Mobile'
                                    : null,
                        prefixIcon: Icon(Icons.phone, color: Appcolors.grey),
                        suffixIcon: IconButton(
                          onPressed: () {
                            if (!formKey.currentState!.validate()) return;
                            final selectedRoomIds =
                                selectedRoomIndexes
                                    .map((i) => roomServerIds[i])
                                    .toList();

                            BleCubit.get(context).addMember(
                              name: nameController.text.trim(),
                              homeId: AppSession.overview.first.home.id,
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                              role:
                                  roleOptions[tagRole], // مش role_Options[tag_type]
                              allowedRoomIds:
                                  selectedRoomIds, // الناتج من الماب فوق
                            );
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
                      // Role chips (single choice)
                      ChipsChoice<int>.single(
                        value: tagRole,
                        onChanged: (val) => setState(() => tagRole = val),
                        choiceItems: C2Choice.listFrom<int, String>(
                          source: roleOptions,
                          value: (i, v) => i,
                          label: (i, v) => v,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Rooms chips (multi choice)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ChipsChoice<int>.multiple(
                          value: selectedRoomIndexes,
                          onChanged:
                              (vals) =>
                                  setState(() => selectedRoomIndexes = vals),
                          choiceItems: C2Choice.listFrom<int, String>(
                            source: roomNames,
                            value: (i, v) => i,
                            label: (i, v) => v,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      condition(
                        context,
                        cond: cubit.myRoomsList.isNotEmpty,
                        child: memberList(cubit.membersList),
                        fall: Text('No Members', style: mystyle(size: 18)),
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
