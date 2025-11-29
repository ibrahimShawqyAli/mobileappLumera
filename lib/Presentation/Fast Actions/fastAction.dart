import 'package:flutter/material.dart';
import 'package:smart_home_iotz/shared/cubit/main_cubit.dart';
import 'package:smart_home_iotz/shared/style/appColors.dart';

class FastAction extends StatelessWidget {
  const FastAction({super.key});

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    final int crossAxisCount = (w / 150).floor().clamp(2, 4);
    var cubit = BleCubit.get(context);
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: w * 0.9,
          height: 80,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Quick Access',
                  style: TextStyle(
                    fontFamily: 'Costaline',
                    color: Color(0xff2980ba),
                    fontSize: 22,
                    fontWeight: FontWeight.w100,
                  ),
                ),
                const Spacer(),
                Image.asset('assets/images/shortcut-script-app.png'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
