import 'dart:convert';
import 'package:fnet_new/static/app_colors.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class MomoCashInCustomersDetails extends StatefulWidget {
  final date_deposited;
  final customersCashIn;
  const MomoCashInCustomersDetails({Key? key,required this.date_deposited,required this.customersCashIn}) : super(key: key);

  @override
  State<MomoCashInCustomersDetails> createState() => _MomoCashInCustomersDetailsState(date_deposited:this.date_deposited,customersCashIn:this.customersCashIn);
}

class _MomoCashInCustomersDetailsState extends State<MomoCashInCustomersDetails> {
  final date_deposited;
  final customersCashIn;
  _MomoCashInCustomersDetailsState({required this.date_deposited,required this.customersCashIn});
  List allCashInForCustomers = [];
  var items;
  bool isLoading = true;
  late String uToken = "";
  final storage = GetStorage();
  late String username = "";
  double sum = 0.0;


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
    for (var i in customersCashIn){
      if(i['date_deposited'] == date_deposited){
        allCashInForCustomers.add(i);
      }
      for(var p in allCashInForCustomers){
        sum = sum + double.parse(p['amount']);
      }

    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Cash in for $date_deposited"),
          backgroundColor:primaryColor
      ),
      body:  ListView.builder(
        itemCount: allCashInForCustomers != null ? allCashInForCustomers.length : 0,
        itemBuilder: (context,index){
          items = allCashInForCustomers[index];
          return Card(
            elevation: 12,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                onTap: (){

                },
                title: Row(
                  children: [
                    const Text("Customer : ",style:TextStyle(fontWeight: FontWeight.bold)),
                    Text(items['customer_phone'],style:const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Row(
                        children: [
                          const Text("Amount : ",style:TextStyle(fontWeight: FontWeight.bold)),
                          Text(items['amount'],style:const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    items['depositor_name'] != "" ? Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Row(
                        children: [
                          const Text("Depositor Name : ",style:TextStyle(fontWeight: FontWeight.bold)),
                          Text(items['depositor_name'],style:const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ): Container(),
                    items['depositor_number'] != "" ?    Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Row(
                        children: [
                          const Text("Depositor # : ",style:TextStyle(fontWeight: FontWeight.bold)),
                          Text(items['depositor_number'],style:const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ) : Container(),
                    Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Row(
                        children: [
                          const Text("Network : ",style:TextStyle(fontWeight: FontWeight.bold)),
                          Text(items['network'],style:const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Row(
                        children: [
                          const Text("Type : ",style:TextStyle(fontWeight: FontWeight.bold)),
                          Text(items['type'],style:const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Row(
                        children: [
                          const Text("Reference : ",style:TextStyle(fontWeight: FontWeight.bold)),
                          Text(items['reference'],style:const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Row(
                        children: [
                          const Text("Date : ",style:TextStyle(fontWeight: FontWeight.bold)),
                          Text(items['date_deposited'],style:const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Row(
                        children: [
                          const Text("Time : ",style:TextStyle(fontWeight: FontWeight.bold)),
                          Text(items['time_deposited'].toString().split(".").first,style:const TextStyle(fontWeight: FontWeight.bold)),
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
