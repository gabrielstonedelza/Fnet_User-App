import 'dart:async';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:fnet_new/payments/paymentsavailable.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:fnet_new/views/withdrawpage.dart';

import 'closeappfortheday.dart';
import 'depositrequest.dart';
import 'homepage.dart';

class MyBottomNavigationBar extends StatefulWidget {
  const MyBottomNavigationBar({Key? key}) : super(key: key);

  @override
  _MyBottomNavigationBarState createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  DateTime datetime = DateTime.now();
  bool isClosingTime = false;
  int selectedIndex = 0;
  final List _pages = [const HomePage(),const Deposits(),const WithdrawalPage(),const PaymentsAvailable()];
  void onSelectedIndex(int index){
    setState(() {
      selectedIndex = index;
    });
  }
  late Timer _timer;

  void checkTheTime(){
    var hour = DateTime.now().hour;
    switch (hour) {
      case 20:
        setState(() {isClosingTime = true;});
        break;
      case 21:
        setState(() {isClosingTime = true;});
        break;
      case 22:
        setState(() {isClosingTime = true;});
        break;
      case 23:
        setState(() {isClosingTime = true;});
        break;
      case 00:
        setState(() {isClosingTime = true;});
        break;
      case 01:
        setState(() {isClosingTime = true;});
        break;
      case 02:
        setState(() {isClosingTime = true;});
        break;
      case 03:
        setState(() {isClosingTime = true;});
        break;
      case 04:
        setState(() {isClosingTime = true;});
        break;
      case 05:
        setState(() {isClosingTime = true;});
        break;
    }
  }
  @override
  void initState(){
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      checkTheTime();
    });

  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      const Icon(Icons.home,size:30),
      Image.asset("assets/images/deposit.png",width: 30,height: 30,),
      Image.asset("assets/images/money-withdrawal.png",width: 30,height: 30,),
      Image.asset("assets/images/cashless-payment.png",width: 30,height: 30,),
      // Image.asset("assets/images/user.png",width: 30,height: 30,),
    ];
    return SafeArea(
      child: Scaffold(
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
