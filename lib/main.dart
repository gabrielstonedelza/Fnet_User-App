import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:fnet_new/views/homepage.dart';
import 'package:fnet_new/views/loginview.dart';
import 'package:fnet_new/views/splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'controllers/accountcontroller.dart';
import 'controllers/logincontroller.dart';
import 'controllers/usercontroller.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await GetStorage.init();
  Get.put(LoginController());
  Get.put(AccountController());
  Get.put(UserController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      // darkTheme: Themes.dark,
      theme: ThemeData(
          // scaffoldBackgroundColor: backgroundColor,
          dividerColor: addBack,
          // textTheme: GoogleFonts.sansitaSwashedTextTheme(Theme.of(context).textTheme),
      ),
      defaultTransition: Transition.leftToRight,
      initialRoute: "/",
      getPages: [
        GetPage(name: "/", page:()=> const Splash()),
        GetPage(name: "/login", page:()=> const LoginView()),
        GetPage(name: "/homepage", page:()=> const HomePage()),
      ],
    );
  }
}

