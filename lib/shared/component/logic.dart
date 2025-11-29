import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';

Widget condition(
  BuildContext context, {
  required bool cond,
  required Widget child,
  required Widget fall,
}) => ConditionalBuilder(
  condition: cond,
  builder: (context) => child,
  fallback: (context) => fall,
);

class NavigateWithAnimation extends PageRouteBuilder {
  final Widget child;
  bool isRight = false;
  NavigateWithAnimation({required this.child, this.isRight = false})
    : super(
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => child,
      );
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => SlideTransition(
    position: Tween<Offset>(
      begin: isRight ? Offset(-1, 0) : Offset(1, 0),
      end: Offset.zero,
    ).animate(animation),
    child: child,
  );
}
