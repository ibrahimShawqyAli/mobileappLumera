import 'package:flutter/material.dart';
import 'package:smart_home_iotz/Presentation/Fast%20Actions/fastAction.dart';
import 'package:smart_home_iotz/Presentation/Rooms%20Widgets/roomWidget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class PageMove extends StatefulWidget {
  PageMove({super.key});

  @override
  State<PageMove> createState() => _PageMoveState();
}

class _PageMoveState extends State<PageMove> {
  final pageController = PageController(initialPage: 0);
  final List<Widget> pages = [RoomWidget(), FastAction()];
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        PageView(controller: pageController, children: pages),
        Positioned(
          bottom: 10,
          child: SmoothPageIndicator(
            controller: pageController, // PageController
            count: pages.length,
            effect: JumpingDotEffect(
              activeDotColor: Colors.black.withOpacity(0.6),
            ), // your preferred effect
            onDotClicked: (index) {},
          ),
        ),
      ],
    );
  }
}
