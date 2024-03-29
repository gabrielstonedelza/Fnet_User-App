import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../static/app_colors.dart';
import '../withdrawals/momowithdrawals.dart';
import 'momowithdrawtransactions.dart';

class MomoWithdrawals extends StatefulWidget {
  const MomoWithdrawals({Key? key}) : super(key: key);

  @override
  State<MomoWithdrawals> createState() => _MomoWithdrawalsState();
}

class _MomoWithdrawalsState extends State<MomoWithdrawals> {
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
            children: [
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      Image.asset("assets/images/momo.png",width: 70,height: 70,),
                      const SizedBox(height: 10,),
                      const Text("Cash Out"),
                    ],
                  ),
                  onTap: (){
                    hasAccountsToday ? Get.to(()=> const MomoWithdraw()): Get.snackbar("Error", "Please add momo accounts for today first",
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
                      const Text(" Transactions"),
                    ],
                  ),
                  onTap: (){
                    Get.to(()=> const MomoWithdrawTransactions());
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
