import 'package:flutter/material.dart';
import 'package:fnet_new/views/withdrawal.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../static/app_colors.dart';

class BankWithdrawals extends StatefulWidget {
  const BankWithdrawals({Key? key}) : super(key: key);

  @override
  State<BankWithdrawals> createState() => _BankWithdrawalsState();
}

class _BankWithdrawalsState extends State<BankWithdrawals> {
  final storage = GetStorage();
  bool hasAccountsToday = false;
  bool isLoading = true;
  late String uToken = "";
  late String username = "";



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(storage.read("accountcreatedtoday") != null){
      setState(() {
        hasAccountsToday = true;
      });
    }
    if(storage.read("usertoken") != null){
      setState(() {
        uToken = storage.read("usertoken");
      });
    }
    if(storage.read("username") != null){
      setState(() {
        username = storage.read("username");
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text('Bank Withdrawal'),
        backgroundColor: primaryColor,
      ),
      body: Column(

        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: GestureDetector(
              onTap: (){
                hasAccountsToday ? Get.to(()=> const WithDrawal()): Get.snackbar("Error", "Please add momo accounts for today first",
                    colorText: defaultTextColor,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red
                );
              },
              child: Column(
                children: [
                  Image.asset("assets/images/money-withdrawal.png",width: 70,height: 70,),
                  const SizedBox(height: 10,),
                  const Text("Bank Withdrawal"),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }
}
