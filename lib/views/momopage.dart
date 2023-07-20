import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:ussd_advanced/ussd_advanced.dart';
import '../deposits/momodeposit.dart';
import '../static/app_colors.dart';
import 'momodeposittransactions.dart';

class MomoPage extends StatefulWidget {
  const MomoPage({Key? key}) : super(key: key);

  @override
  State<MomoPage> createState() => _MomoPageState();
}

class _MomoPageState extends State<MomoPage> {
  final storage = GetStorage();
  bool hasAccountsToday = false;
  bool isLoading = true;
  late String uToken = "";
  late String  rs = "";

  Future<void> checkMtnCommission() async {
    UssdAdvanced.multisessionUssd(code: "*171*7*2*1#",subscriptionId: 1);
  }
  Future<void> checkMtnBalance() async {
     await UssdAdvanced.multisessionUssd(code: "*171*7*1#",subscriptionId: 1);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(storage.read("accountcreatedtoday") != null){
      setState(() {
        hasAccountsToday = true;
      });
    }
    else{
      setState(() {
        hasAccountsToday = false;
      });
    }
    if(storage.read("usertoken") != null){
      setState(() {
        uToken = storage.read("usertoken");
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Momo Transactions"),
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
                      Image.asset("assets/images/momo.png",width: 70,height: 70,),
                      const SizedBox(height: 10,),
                      const Text("Pay To"),
                    ],
                  ),
                  onTap: (){
                    hasAccountsToday ? Get.to(()=> const MomoDeposit()): Get.snackbar("Error", "Please add momo accounts for today first",
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
                      const Text(" Transactions"),
                    ],
                  ),
                  onTap: (){
                    showMaterialModalBottomSheet(
                      context: context,
                      builder: (context) => SizedBox(
                        height: 150,
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // GestureDetector(
                              //   onTap: (){
                              //     // Get.to(() => const MomoDepositsTransactions());
                              //     // Get.back();
                              //   },
                              //   child: Column(
                              //     children: [
                              //       Image.asset("assets/images/money-withdrawal.png",width:50,height: 50,),
                              //       const Padding(
                              //         padding: EdgeInsets.only(top:10.0),
                              //         child: Text("Cash Out",style:TextStyle(fontWeight: FontWeight.bold)),
                              //       )
                              //     ],
                              //   ),
                              // ),
                              GestureDetector(
                                onTap: (){
                                  Get.to(() => const MomoDepositsTransactions());
                                },
                                child: Column(
                                  children: [
                                    Image.asset("assets/images/deposit1.png",width:50,height: 50,),
                                    const Padding(
                                      padding: EdgeInsets.only(top:10.0),
                                      child: Text("Pay To",style:TextStyle(fontWeight: FontWeight.bold)),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      // Image.asset("assets/images/momo.png",width: 70,height: 70,),
                      // const SizedBox(height: 10,),
                      // const Text("Cash Out"),
                    ],
                  ),
                  onTap: (){
                    // hasAccountsToday ? Get.to(()=> const MomoWithdraw()): Get.snackbar("Error", "Please add momo accounts for today first",
                    //     colorText: defaultTextColor,
                    //     snackPosition: SnackPosition.BOTTOM,
                    //     backgroundColor: Colors.red
                    // );
                  },
                ),
              ),

            ],
          ),
        ],
      )
    );
  }
}
