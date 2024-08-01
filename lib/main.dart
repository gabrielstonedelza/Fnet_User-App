import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:fnet_new/views/homepage.dart';
import 'package:fnet_new/views/loginview.dart';
import 'package:fnet_new/views/splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:telephony/telephony.dart';

import 'controllers/accountcontroller.dart';
import 'controllers/locationcontroller.dart';
import 'controllers/logincontroller.dart';
import 'controllers/usercontroller.dart';

onBackgroundMessage(SmsMessage message) {
  debugPrint("onBackgroundMessage called");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await GetStorage.init();
  Get.put(LoginController());
  Get.put(AccountController());
  Get.put(UserController());
  Get.put(LocationController());
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _message = "";
  final telephony = Telephony.instance;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  onMessage(SmsMessage message) async {
    setState(() {
      _message = message.body ?? "Error reading message body.";
    });
  }

  onSendStatus(SendStatus status) {
    setState(() {
      _message = status == SendStatus.SENT ? "sent" : "delivered";
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    final bool? result = await telephony.requestPhoneAndSmsPermissions;

    if (result != null && result) {
      telephony.listenIncomingSms(
          onNewMessage: onMessage, onBackgroundMessage: onBackgroundMessage);
    }

    if (!mounted) return;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      // darkTheme: Themes.dark,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: defaultTextColor1,
              fontSize: 18),
          elevation: 0,
          backgroundColor: snackColor,
        ),
        // scaffoldBackgroundColor: backgroundColor,
        dividerColor: addBack,
        // textTheme: GoogleFonts.sansitaSwashedTextTheme(Theme.of(context).textTheme),
      ),
      defaultTransition: Transition.leftToRight,
      initialRoute: "/",
      getPages: [
        GetPage(name: "/", page: () => const Splash()),
        GetPage(name: "/login", page: () => const LoginView()),
        GetPage(name: "/homepage", page: () => HomePage(message: _message)),
      ],
    );
  }
}
