import 'package:flutter/material.dart';
import 'package:fnet_new/accounts/paymentsummary.dart';
import 'package:fnet_new/accounts/tigodepositsummary.dart';
import 'package:fnet_new/accounts/tigowithdrawalsummary.dart';
import 'package:fnet_new/accounts/vodafonedepositsummary.dart';
import 'package:fnet_new/accounts/vodafonewithdrawalsummary.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:get/get.dart';

import 'agent2agent.dart';
import 'bankrequestsummary.dart';
import 'bankwithdrawalsummary.dart';
import 'cashrequestsummary.dart';
import 'mtndepositsummary.dart';
import 'mtnwithdrawsummary.dart';

class TransactionSummary extends StatelessWidget {
  const TransactionSummary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Summary"),
        backgroundColor: primaryColor,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 30,),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      Image.asset("assets/images/business-report.png",width: 70,height: 70,),
                      const SizedBox(height: 10,),
                      const Text("Bank"),
                      const Text("Summary"),
                    ],
                  ),
                  onTap: (){
                    Get.to(()=> const BankRequestSummary());
                  },
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      Image.asset("assets/images/business-report.png",width: 70,height: 70,),
                      const SizedBox(height: 10,),
                      const Text("Cash "),
                      const Text("Summary"),
                    ],
                  ),
                  onTap: (){
                    Get.to(()=> const CashRequestSummary());

                  },
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      Image.asset("assets/images/business-report.png",width: 70,height: 70,),
                      const SizedBox(height: 10,),
                      const Text("Payment "),
                      const Text("Summary"),
                    ],
                  ),
                  onTap: (){
                    Get.to(()=> const PaymentRequestSummary());
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height:10),
          const Divider(),
          const SizedBox(height:10),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      Image.asset("assets/images/business-report.png",width: 70,height: 70,),
                      const SizedBox(height: 10,),
                      const Text("Bank Withdrawal"),
                      const Text("Summary"),
                    ],
                  ),
                  onTap: (){
                    Get.to(()=> const BankWithdrawalSummary());
                  },
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      // Image.asset("assets/images/business-report.png",width: 70,height: 70,),
                      // const SizedBox(height: 10,),
                      // const Text("Cash "),
                      // const Text("Summary"),
                    ],
                  ),
                  onTap: (){
                    // Get.to(()=> const CashRequestSummary());

                  },
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      // Image.asset("assets/images/business-report.png",width: 70,height: 70,),
                      // const SizedBox(height: 10,),
                      // const Text("Payment "),
                      // const Text("Summary"),
                    ],
                  ),
                  onTap: (){
                    // Get.to(()=> const PaymentRequestSummary());
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height:10),
          const Divider(),
          const SizedBox(height:10),
          const Center(
            child: Text("Momo Pay To",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold))
          ),
          const SizedBox(height:20),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      Image.asset("assets/images/business-report.png",width: 70,height: 70,),
                      const SizedBox(height: 10,),
                      const Text("MTN"),
                      const Text("Summary"),
                    ],
                  ),
                  onTap: (){
                    Get.to(()=> const MtnDepositSummary());
                  },
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      Image.asset("assets/images/business-report.png",width: 70,height: 70,),
                      const SizedBox(height: 10,),
                      const Text("Agent 2 Agent"),
                      const Text("Summary"),
                    ],
                  ),
                  onTap: (){
                    Get.to(()=> const AgentToAgentDepositSummary());
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height:10),
          const Divider(),
          const SizedBox(height:10),
          Row(
            children: [

              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      // Image.asset("assets/images/business-report.png",width: 70,height: 70,),
                      // const SizedBox(height: 10,),
                      // const Text("Tigo "),
                      // const Text("Summary"),
                    ],
                  ),
                  onTap: (){
                    // Get.to(()=> const CashRequestSummary());

                  },
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      // Image.asset("assets/images/business-report.png",width: 70,height: 70,),
                      // const SizedBox(height: 10,),
                      // const Text("Vodafone "),
                      // const Text("Summary"),
                    ],
                  ),
                  onTap: (){
                    // Get.to(()=> const PaymentRequestSummary());
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height:10),
          const Divider(),
          const SizedBox(height:10),
          // const Center(
          //     child: Text("Momo Withdraws",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold))
          // ),
          const SizedBox(height:20),
          // Row(
          //   children: [
          //     Expanded(
          //       child: GestureDetector(
          //         child: Column(
          //           children: [
          //             Image.asset("assets/images/business-report.png",width: 70,height: 70,),
          //             const SizedBox(height: 10,),
          //             const Text("MTN"),
          //             const Text("Summary"),
          //           ],
          //         ),
          //         onTap: (){
          //           Get.to(()=> const MtnWithDrawSummary());
          //         },
          //       ),
          //     ),
          //     Expanded(
          //       child: GestureDetector(
          //         child: Column(
          //           children: [
          //             Image.asset("assets/images/business-report.png",width: 70,height: 70,),
          //             const SizedBox(height: 10,),
          //             const Text("Tigo "),
          //             const Text("Summary"),
          //           ],
          //         ),
          //         onTap: (){
          //           Get.to(()=> const TigoWithDrawSummary());
          //
          //         },
          //       ),
          //     ),
          //     Expanded(
          //       child: GestureDetector(
          //         child: Column(
          //           children: [
          //             Image.asset("assets/images/business-report.png",width: 70,height: 70,),
          //             const SizedBox(height: 10,),
          //             const Text("Vodafone "),
          //             const Text("Summary"),
          //           ],
          //         ),
          //         onTap: (){
          //           Get.to(()=> const VodafoneWithDrawSummary());
          //         },
          //       ),
          //     ),
          //   ],
          // ),

        ],
      ),
    );
  }
}
