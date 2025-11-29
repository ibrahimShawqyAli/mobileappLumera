import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home_iotz/Presentation/home/homeScreen.dart';
import 'package:smart_home_iotz/shared/component/inputComponent.dart';
import 'package:smart_home_iotz/shared/component/logic.dart';
import 'package:smart_home_iotz/shared/component/presentationComponent.dart';

import 'package:smart_home_iotz/shared/cubit/startupCubit.dart';
import 'package:smart_home_iotz/shared/cubit/startupState.dart';
import 'package:smart_home_iotz/shared/style/appColors.dart';
import 'package:smart_home_iotz/shared/variables/variables.dart';

class GetStarted extends StatefulWidget {
  const GetStarted({super.key});

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isFinished = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h =
        MediaQuery.of(context).size.height > 750
            ? MediaQuery.of(context).size.height
            : 750;
    var cubit = StartupCubit.get(context);
    return BlocConsumer<StartupCubit, StartupState>(
      listener: (context, state) {},
      builder:
          (context, state) => Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  width: w,
                  height: h,
                  color: Appcolors.myBK(theme),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedPositioned(
                        duration: Duration(milliseconds: 700),
                        curve: Curves.easeOut,
                        top: cubit.animationIndex > 2 ? -0.25 * h : 0,
                        child: Container(
                          width: w,
                          height: h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: Appcolors.backGroundGetStarted,
                            ),
                          ),
                        ),
                      ),
                      AnimatedPositioned(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        top: cubit.animationIndex > 3 ? 0.05 * h : h,
                        child: AnimatedOpacity(
                          opacity: cubit.animationIndex > 2 ? 1 : 0,
                          duration: Duration(seconds: 2), // 2 seconds fade-in
                          child: SizedBox(
                            width: w,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Lumera',
                                  textAlign: TextAlign.center,
                                  style: mystyle(
                                    size: 28,
                                    color: Appcolors.white,
                                  ),
                                ),

                                Image.asset(
                                  'assets/images/Home Illustrations.png',
                                  width: w * 0.8,
                                ),
                                SizedBox(
                                  width: w * 0.8,
                                  child:
                                      cubit.animationIndex > 3
                                          ? AnimatedTextKit(
                                            animatedTexts: [
                                              TyperAnimatedText(
                                                'Welcome Sign In to manage your devices.',
                                                textAlign: TextAlign.center,
                                                textStyle: mystyle(
                                                  size: 14,
                                                  color: Appcolors.white,
                                                ),
                                                speed: Duration(
                                                  milliseconds: 50,
                                                ),
                                              ),
                                            ],
                                            totalRepeatCount: 1,
                                            pause: Duration(milliseconds: 500),
                                            displayFullTextOnTap: true,
                                            stopPauseOnTap: true,
                                            onFinished: () {},
                                          )
                                          : SizedBox.shrink(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      AnimatedPositioned(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        top: cubit.animationIndex > 4 ? 0.51 * h : h,
                        child: AnimatedOpacity(
                          opacity: cubit.animationIndex > 2 ? 1 : 0,
                          duration: Duration(seconds: 2),
                          child: SizedBox(
                            width: w * 0.85,
                            child: inputText(
                              context,
                              controller: _emailController,
                              hintText: 'Email',
                              suffixIcon: Icon(
                                Icons.email,
                                size: 30,
                                color: Appcolors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),

                      AnimatedPositioned(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        top: cubit.animationIndex > 5 ? (0.51 * h) + 70 : h,
                        child: AnimatedOpacity(
                          opacity: cubit.animationIndex > 2 ? 1 : 0,
                          duration: Duration(seconds: 2),
                          child: SizedBox(
                            width: w * 0.85,
                            child: inputText(
                              context,

                              controller: _passwordController,
                              isSecure: true,
                              hintText: 'Password',
                              suffixIcon: Icon(
                                Icons.lock_rounded,
                                size: 30,
                                color: Appcolors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),

                      AnimatedPositioned(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        top: cubit.animationIndex > 6 ? (0.75 * h) - 40 : h,
                        child: AnimatedOpacity(
                          opacity: cubit.animationIndex > 2 ? 1 : 0,
                          duration: Duration(seconds: 2),
                          child: IconButton(
                            onPressed: () {
                              StartupCubit.get(context).login(
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                              );
                            },
                            icon: BlocConsumer<StartupCubit, StartupState>(
                              listener: (context, state) {
                                if (state is LoginSuccess) {
                                  Navigator.pushReplacement(
                                    context,
                                    NavigateWithAnimation(child: Homescreen()),
                                  );
                                }
                                if (state is LoginError) {
                                  showToast(state.error);
                                }
                              },
                              builder: (context, state) {
                                return Container(
                                  width: 160,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: Appcolors.loginGradient,
                                    ),
                                  ),
                                  child: Center(
                                    child:
                                        state is LoginLoading
                                            ? CircularProgressIndicator(
                                              color: Colors.white,
                                            )
                                            : Text(
                                              'Log in',
                                              style: mystyle(
                                                size: 24,
                                                color: Appcolors.white,
                                              ),
                                            ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        top: 0.81 * h,
                        child:
                            cubit.animationIndex > 10
                                ? AnimatedTextKit(
                                  animatedTexts: [
                                    TyperAnimatedText(
                                      ' Don’t have an account yet?',
                                      textAlign: TextAlign.center,
                                      textStyle: mystyle(
                                        size: 16,
                                        color: Appcolors.grey,
                                      ),
                                      speed: Duration(milliseconds: 90),
                                    ),
                                  ],
                                  totalRepeatCount: 1,
                                  pause: Duration(milliseconds: 1000),
                                  displayFullTextOnTap: true,
                                  stopPauseOnTap: true,
                                  onFinished: () {
                                    setState(() {
                                      isFinished = true;
                                    });
                                  },
                                )
                                : SizedBox(),
                      ),
                      Positioned(
                        top: 0.81 * h + 20,
                        child: AnimatedOpacity(
                          opacity: isFinished ? 1 : 0,
                          duration: Duration(seconds: 2),
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              ' Create an account',
                              style: mystyle(size: 18, color: Appcolors.grey),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }
}
