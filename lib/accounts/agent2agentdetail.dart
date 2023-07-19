import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import '../loadingui.dart';

class A2ADepositSummaryDetail extends StatefulWidget {
  final deposit_date;
  const A2ADepositSummaryDetail({Key? key,this.deposit_date}) : super(key: key);

  @override
  _A2ADepositSummaryDetailState createState() => _A2ADepositSummaryDetailState(deposit_date: this.deposit_date);
}

class _A2ADepositSummaryDetailState extends State<A2ADepositSummaryDetail> {
  final deposit_date;
  _A2ADepositSummaryDetailState({required this.deposit_date});
  late String username = "";
  final storage = GetStorage();
  bool hasToken = false;
  late String uToken = "";
  late List allA2ADeposits = [];
  bool isLoading = true;
  late var items;
  late List amounts = [];
  late List amountResults = [];
  late List depositsDates = [];
  double sum = 0.0;

  fetchUserA2ADeposits()async{
    const url = "https://fnetghana.xyz/get_user_momo_agent_to_agent_summary";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allA2ADeposits = json.decode(jsonData);
      amounts.assignAll(allA2ADeposits);
      for(var i in amounts){
        if(i['date_deposited'] == deposit_date){
          depositsDates.add(i);
          sum = sum + double.parse(i['amount']);
        }
      }
    }

    setState(() {
      isLoading = false;
      allA2ADeposits = allA2ADeposits;
      depositsDates = depositsDates;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(storage.read("username") != null){
      setState(() {
        username = storage.read("username");
      });
    }

    if(storage.read("usertoken") != null){
      setState(() {
        hasToken = true;
        uToken = storage.read("usertoken");
      });
    }
    fetchUserA2ADeposits();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Agent to Agent"),
      ),
      body: SafeArea(
          child:
          isLoading ? const LoadingUi() : ListView.builder(
              itemCount: depositsDates != null ? depositsDates.length : 0,
              itemBuilder: (context,i){
                items = depositsDates[i];
                return Column(
                  children: [
                    const SizedBox(height: 20,),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0,right: 8),
                      child: Card(
                        color: secondaryColor,
                        elevation: 12,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        // shadowColor: Colors.pink,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 18.0,bottom: 18),
                          child: ListTile(
                            title: Padding(
                              padding: const EdgeInsets.only(bottom: 15.0),
                              child: Row(
                                children: [
                                  const Text("Customer: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                  Text(items['customer_phone'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                ],
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text("Amount: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),

                                    Text(items['amount'],style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.white),),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text("Commission: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),

                                    Text(items['agent_commission'],style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.white),),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text("Date: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),

                                    Text(items['date_deposited'],style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.white),),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text("Time: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),

                                    Text(items['time_deposited'].toString().split(".").first,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.white),),
                                  ],
                                ),

                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                );
              }
          )
      ),
      floatingActionButton: !isLoading ? FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Text("Total"),
        onPressed: (){
          Get.defaultDialog(
            buttonColor: primaryColor,
            title: "Total",
            middleText: "$sum",
            confirm: RawMaterialButton(
                shape: const StadiumBorder(),
                fillColor: primaryColor,
                onPressed: (){
                  Get.back();
                }, child: const Text("Close",style: TextStyle(color: Colors.white),)),
          );

        },
      ):Container(),
    );
  }
}
