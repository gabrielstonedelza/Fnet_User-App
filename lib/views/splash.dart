import 'package:flutter/material.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:fnet_new/views/bottomnavigation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:splash_screen_view/SplashScreenView.dart';

import 'homepage.dart';
import 'loginview.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  final storage = GetStorage();
  late String username = "";
  bool hasToken = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(storage.read("username") != null){
      username = storage.read("username");
      setState(() {
        hasToken = true;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return SplashScreenView(
      navigateRoute: hasToken ? const MyBottomNavigationBar() : const LoginView(),
      duration: 4000,
      imageSize: 200,
      imageSrc: "assets/images/logo.png",
      text: "Swift And Reliable",
      textType: TextType.TyperAnimatedText,
      textStyle: const TextStyle(
          fontSize: 30.0,
          color: primaryColor
      ),
      backgroundColor: Colors.white,
    );
  }
}
