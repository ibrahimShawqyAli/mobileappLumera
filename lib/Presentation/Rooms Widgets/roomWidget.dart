import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:smart_home_iotz/Presentation/RoomsDetailsScreen.dart';
import 'package:smart_home_iotz/Presentation/home/homeScreen.dart';
import 'package:smart_home_iotz/shared/DB/db.dart';
import 'package:smart_home_iotz/shared/component/logic.dart';
import 'package:smart_home_iotz/shared/component/presentationComponent.dart';
import 'package:smart_home_iotz/shared/cubit/main/main_cubit.dart';
import 'package:smart_home_iotz/shared/cubit/main_cubit.dart';
import 'package:smart_home_iotz/shared/cubit/main_state.dart';
import 'package:smart_home_iotz/shared/style/appColors.dart';
import 'package:smart_home_iotz/shared/variables/variables.dart';
import 'package:smart_home_iotz/shared/web/hub.dart';

class RoomWidget extends StatelessWidget {
  const RoomWidget({super.key});

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    final int crossAxisCount = (w / 150).floor().clamp(2, 4);
    var cubit = BleCubit.get(context);
    return BlocConsumer<BleCubit, BleState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: w * 0.9,
                  height: 130,
                  decoration: BoxDecoration(
                    color: Appcolors.myBK(theme),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4,
                        color: Colors.black.withOpacity(0.5),
                        offset: Offset(4, 0),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Energy Consumption',
                              style: mystyle(
                                size: 18,
                                color: theme ? Colors.black87 : Colors.white,
                                isBold: true,
                              ),
                            ),
                            Text(
                              '32.1kw',
                              style: TextStyle(
                                fontFamily: 'Costaline',
                                color: Color(0xff00ab5e),
                                fontSize: 40,
                                fontWeight: FontWeight.w100,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Image.asset('assets/images/energy.png'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                ReorderableGridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: List.generate(cubit.myRoomsList.length, (index) {
                    final room = cubit.myRoomsList[index];
                    return KeyedSubtree(
                      key: ValueKey(room.name),
                      child: InkWell(
                        onTap: () async {
                          cubit.getRoomDevices(room.id);
                          try {
                            await SocketHub.init(myWebSocketServer);
                          } catch (e, st) {
                            debugPrint('SocketHub.init error: $e');
                            debugPrint(st.toString());
                          }
                          Navigator.push(
                            context,
                            NavigateWithAnimation(
                              child: RoomDetailsScreen(
                                roomId: room.serverId,
                                roomName: room.name,
                                roommImage: room.iconPath,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          // key: ValueKey(room.name),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 4,
                                color: Colors.black.withOpacity(0.5),
                                offset: Offset(4, 0),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  room.iconPath,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.vertical(
                                      bottom: Radius.circular(12),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      room.name,
                                      style: mystyle(
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  onReorder: (oldIndex, newIndex) async {
                    final item = cubit.myRoomsList.removeAt(oldIndex);
                    cubit.myRoomsList.insert(newIndex, item);
                    await DBHelper.updateRoomSortOrder(
                      cubit.myRoomsList.map((room) => room.id).toList(),
                    );
                    cubit.emit(BleInitial());
                  },
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}
