import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:fnet_new/payments/paymentsavailable.dart';
import 'package:fnet_new/static/app_colors.dart';
import "package:get/get.dart";
import 'accountblocked.dart';
import 'closeappfortheday.dart';
import 'depositrequest.dart';
import 'homepage.dart';
import 'loginview.dart';
import 'momopage.dart';

class MyBottomNavigationBar extends StatefulWidget {
  const MyBottomNavigationBar({Key? key}) : super(key: key);

  @override
  _MyBottomNavigationBarState createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  late String username = "";
  bool hasToken = false;
  late String uToken = "";
  final storage = GetStorage();
  late List allBlockedUsers = [];
  late List blockedUsernames = [];
  DateTime datetime = DateTime.now();
  bool isLoading = true;
  bool isClosingTime = false;
  int selectedIndex = 0;
  bool isBlocked = false;
  final List _pages = [const HomePage(message: null,),const MomoPage(),const Deposits(),const PaymentsAvailable()];
  void onSelectedIndex(int index){
    setState(() {
      selectedIndex = index;
    });
  }
  late Timer _timer;
  fetchBlockedAgents()async{
    const url = "https://fnetghana.xyz/get_all_blocked_users/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink,);
    if(response.statusCode == 200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allBlockedUsers = json.decode(jsonData);
      for(var i in allBlockedUsers){
        if(!blockedUsernames.contains(i['username'])){
          blockedUsernames.add(i['username']);
        }
      }
    }
    // setState(() {
    //   isLoading = false;
    // });
  }
  logoutUser() async {
    storage.remove("username");
    storage.remove("usertoken");
    Get.offAll(() => const LoginView());
    const logoutUrl = "https://www.fnetghana.xyz/auth/token/logout";
    final myLink = Uri.parse(logoutUrl);
    http.Response response = await http.post(myLink, headers: {
      'Accept': 'application/json',
      "Authorization": "Token $uToken"
    });

    if (response.statusCode == 200) {
      Get.snackbar("Success", "You were logged out",
          colorText: defaultTextColor,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackColor);
      storage.remove("username");
      storage.remove("usertoken");
      Get.offAll(() => const LoginView());
    }
  }

  void checkTheTime(){
    var hour = DateTime.now().hour;
    switch (hour) {
      case 20:
        setState(() {isClosingTime = true;});
        logoutUser();
        break;
      case 21:
        setState(() {isClosingTime = true;});
        logoutUser();
        break;
      case 22:
        setState(() {isClosingTime = true;});
        logoutUser();
        break;
      case 23:
        setState(() {isClosingTime = true;});
        logoutUser();
        break;
      case 00:
        setState(() {isClosingTime = true;});
        logoutUser();
        break;
      case 01:
        setState(() {isClosingTime = true;});
        logoutUser();
        break;
      case 02:
        setState(() {isClosingTime = true;});
        logoutUser();
        break;
      case 03:
        setState(() {isClosingTime = true;});
        logoutUser();
        break;
      case 04:
        setState(() {isClosingTime = true;});
        logoutUser();
        break;
      case 05:
        setState(() {isClosingTime = true;});
        logoutUser();
        break;
    }
  }
  @override
  void initState(){
    super.initState();
    if (storage.read("username") != null) {
      setState(() {
        username = storage.read("username");
      });
    }
    if (storage.read("usertoken") != null) {
      setState(() {
        hasToken = true;
        uToken = storage.read("usertoken");
      });
    }
    fetchBlockedAgents();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      checkTheTime();
    });
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchBlockedAgents();
    });

  }

  @override
  void dispose(){
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      const Icon(Icons.home,size:30),
      Image.asset("assets/images/momo.png",width: 30,height: 30,),
      Image.asset("assets/images/deposit.png",width: 30,height: 30,),
      Image.asset("assets/images/cashless-payment.png",width: 30,height: 30,),
      // Image.asset("assets/images/user.png",width: 30,height: 30,),
    ];
    return SafeArea(
      child: blockedUsernames.contains(username) ? const Scaffold(
        body: AccountBlockNotification()
      ) :Scaffold(
        extendBody: true,
        body:isClosingTime ? const CloseAppForDay() : _pages[selectedIndex],
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            iconTheme: const IconThemeData(color:Colors.white)
          ),
          child: CurvedNavigationBar(
            color: primaryColor,
              buttonBackgroundColor: primaryColor,
              items: items,
              height: 60,
              index: selectedIndex,
              onTap: onSelectedIndex,
            backgroundColor: Colors.transparent,
            animationCurve: Curves.easeInOut,
            animationDuration: const Duration(milliseconds:300)
          ),
        ),
      ),
    );
  }
}
