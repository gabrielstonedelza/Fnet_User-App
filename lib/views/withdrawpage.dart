
import 'package:flutter/material.dart';

import 'package:fnet_new/static/app_colors.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'justbankwithdrawals.dart';
import 'justmomowithdrawals.dart';

class WithdrawalPage extends StatefulWidget {
  const WithdrawalPage({Key? key}) : super(key: key);

  @override
  State<WithdrawalPage> createState() => _WithdrawalPageState();
}

class _WithdrawalPageState extends State<WithdrawalPage> {
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
        title: const Text("Select Withdrawal type"),
        backgroundColor: primaryColor,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 40,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      Image.asset("assets/images/bank.png",width: 70,height: 70,),
                      const SizedBox(height: 10,),
                      const Text("Bank"),
                    ],
                  ),
                  onTap: (){
                    hasAccountsToday ? Get.to(()=> const BankWithdrawals()): Get.snackbar("Error", "Please add momo accounts for today first",
                        colorText: defaultTextColor,
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red
                    );

                  },
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      Image.asset("assets/images/momo.png",width: 70,height: 70,),
                      const SizedBox(height: 10,),
                      const Text("Momo"),
                    ],
                  ),
                  onTap: (){
                    hasAccountsToday ? Get.to(()=> const MomoWithdrawals()): Get.snackbar("Error", "Please add momo accounts for today first",
                        colorText: defaultTextColor,
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red
                    );
                  },
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }
}

