import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import '../loadingui.dart';

class UserPaymentDetail extends StatefulWidget {
  final paydate;
  const UserPaymentDetail({Key? key,this.paydate}) : super(key: key);

  @override
  _UserPaymentDetailState createState() => _UserPaymentDetailState(paydate:this.paydate);
}

class _UserPaymentDetailState extends State<UserPaymentDetail> {

  final paydate;
  _UserPaymentDetailState({required this.paydate});
  late String username = "";
  final storage = GetStorage();
  bool hasToken = false;
  late String uToken = "";
  late List allUserPayments = [];
  bool isLoading = true;
  late var items;
  late List amounts = [];
  late List paymentDates = [];
  double sum = 0.0;

  fetchUserPayments()async{
    const url = "https://fnetghana.xyz/user_total_payments/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allUserPayments = json.decode(jsonData);
      amounts.assignAll(allUserPayments);
      for(var i in amounts){
        if(i['date_created'] == paydate){
          paymentDates.add(i);
          sum = sum + double.parse(i['amount']);
        }
      }
    }

    setState(() {
      isLoading = false;
      paymentDates = paymentDates;
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
    fetchUserPayments();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text("$username's Payments"),
      ),
      body: SafeArea(
          child:
          isLoading ? const LoadingUi() : ListView.builder(
              itemCount: paymentDates != null ? paymentDates.length : 0,
              itemBuilder: (context,i){
                items = paymentDates[i];
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
                                  const Text("Mode of Payment1: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white)),
                                  Text(items['mode_of_payment1'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                ],
                              ),
                            ),
                            subtitle: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text("Mode of Payment2: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                    Text(items['mode_of_payment2'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                  ],
                                ),

                                items['mode_of_payment1'] == "Cash left @" || items['mode_of_payment2'] == "Cash left @" ? Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Text("Cash Left At1: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),

                                        Text(items['cash_at_location1'],style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.white),),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text("Cash Left At2: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),

                                        Text(items['cash_at_location2'],style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.white),),
                                      ],
                                    ),
                                  ],
                                ) : Container(),
                                Row(
                                  children: [
                                    const Text("Amount1: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                    Text(items['amount1'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text("Amount2: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                    Text(items['amount2'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                  ],
                                ),

                                Row(
                                  children: [
                                    const Text("Date: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                    Text(items['date_created'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text("Time : ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                    Text(items['time_created'].toString().split(".").first,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                  ],
                                ),
                                const SizedBox(height: 20,),
                                const Divider(),
                                const SizedBox(height: 20,),
                                Row(
                                  children: [
                                    const Text("Total Amount: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                    Text(items['amount'].toString().split(".").first,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Text("Total"),
        onPressed: (){
          Get.defaultDialog(
            buttonColor: primaryColor,
            title: "Payment Total",
            middleText: "$sum",
            confirm: RawMaterialButton(
                shape: const StadiumBorder(),
                fillColor: primaryColor,
                onPressed: (){
                  Get.back();
                }, child: const Text("Close",style: TextStyle(color: Colors.white),)),
          );

        },
      ),
    );
  }
}
