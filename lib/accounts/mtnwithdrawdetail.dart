import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class MtnWithdrawalSummaryDetail extends StatefulWidget {
  final withdrawal_date;
  const MtnWithdrawalSummaryDetail({Key? key,this.withdrawal_date}) : super(key: key);

  @override
  _MtnWithdrawalSummaryDetailState createState() => _MtnWithdrawalSummaryDetailState(withdrawal_date: this.withdrawal_date);
}

class _MtnWithdrawalSummaryDetailState extends State<MtnWithdrawalSummaryDetail> {
  final withdrawal_date;
  _MtnWithdrawalSummaryDetailState({required this.withdrawal_date});
  late String username = "";
  final storage = GetStorage();
  bool hasToken = false;
  late String uToken = "";
  late List allMtnWithdraws = [];
  bool isLoading = true;
  late var items;
  late List amounts = [];
  late List amountResults = [];
  late List withdrawalDates = [];
  double sum = 0.0;

  fetchUserMtnWithdraws()async{
    const url = "https://fnetghana.xyz/get_user_mtn_withdrawal";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allMtnWithdraws = json.decode(jsonData);
      amounts.assignAll(allMtnWithdraws);
      for(var i in amounts){
        if(i['date_of_withdrawal'] == withdrawal_date){
          withdrawalDates.add(i);
          sum = sum + double.parse(i['amount']);
        }
      }
    }

    setState(() {
      isLoading = false;
      allMtnWithdraws = allMtnWithdraws;
      withdrawalDates = withdrawalDates;
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
    fetchUserMtnWithdraws();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Mtn withdraws"),
      ),
      body: SafeArea(
          child:
          isLoading ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                    strokeWidth: 5,
                  )
              ),
            ],
          ) : ListView.builder(
              itemCount: withdrawalDates != null ? withdrawalDates.length : 0,
              itemBuilder: (context,i){
                items = withdrawalDates[i];
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
                                    const Text("Withdrawal date: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),

                                    Text(items['date_of_withdrawal'],style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.white),),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text("Withdrawal time: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),

                                    Text(items['time_of_withdrawal'].toString().split(".").first,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.white),),
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
      floatingActionButton: !isLoading ?FloatingActionButton(
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
