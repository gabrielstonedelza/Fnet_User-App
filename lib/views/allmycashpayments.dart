import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import 'mycashpaymentdetail.dart';

class AllMyCashPayments extends StatefulWidget {
  const AllMyCashPayments({Key? key}) : super(key: key);

  @override
  State<AllMyCashPayments> createState() => _AllMyCashPaymentsState();
}

class _AllMyCashPaymentsState extends State<AllMyCashPayments> {
  List allCashPaymentsDates = [];
  List allCashPayments = [];

  var items;
  bool isLoading = true;
  late String uToken = "";
  final storage = GetStorage();
  late String username = "";
  double sum = 0.0;

  Future<void> fetchCashPayments() async {
    const url = "https://fnetghana.xyz/get_all_my_cash_payments/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    },);

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      var agents = json.decode(jsonData);
      allCashPayments.assignAll(agents);
      for(var i in allCashPayments){

        if(!allCashPaymentsDates.contains(i['date_created'])){
          sum = sum + double.parse(i['amount']);
          allCashPaymentsDates.add(i['date_created']);
        }
      }

    }
    setState(() {
      isLoading = false;

    });
  }

  @override
  void initState(){
    super.initState();
    if (storage.read("usertoken") != null) {
      setState(() {
        uToken = storage.read("usertoken");
      });
    }
    if (storage.read("username") != null) {
      setState(() {
        username = storage.read("username");
      });
    }
    fetchCashPayments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text("My Cash Payments"),
        backgroundColor:primaryColor
      ),
      body: isLoading ? const Center(
        child: CircularProgressIndicator()
      ): ListView.builder(
        itemCount: allCashPaymentsDates != null ? allCashPaymentsDates.length : 0,
        itemBuilder: (context,index){
          items = allCashPaymentsDates[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 12,
              child:ListTile(
                onTap: (){
                  Get.to(() => MyCashPaymentDetails(date_created: allCashPaymentsDates[index],));
                },
                title: Row(
                  children: [
                    const Text("Date : "),
                    Text(items),
                  ],
                )
              )
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
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
      ),
    );
  }
}
