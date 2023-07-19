import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import '../loadingui.dart';
import '../userbankrequestdetail.dart';

class BankRequestSummary extends StatefulWidget {
  const BankRequestSummary({Key? key}) : super(key: key);

  @override
  _BankRequestSummaryState createState() => _BankRequestSummaryState();
}

class _BankRequestSummaryState extends State<BankRequestSummary> {

  late String username = "";
  final storage = GetStorage();
  bool hasToken = false;
  late String uToken = "";
  late List allBankRequest = [];
  var items;
  bool isLoading = true;
  late List amounts = [];
  late List bankAmounts = [];
  late List requestDates = [];
  double sum = 0.0;

  fetchAllBankRequest()async{
    const url = "https://fnetghana.xyz/get_agents_bank_total_by_date/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allBankRequest = json.decode(jsonData);
      amounts = allBankRequest;
      for(var i in amounts){
        sum = sum + double.parse(i['amount']);
        if(!requestDates.contains(i['date_requested'])){
          requestDates.add(i['date_requested']);
        }
      }
    }

    setState(() {
      isLoading = false;
      requestDates = requestDates;
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
    fetchAllBankRequest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bank Summary"),
        backgroundColor: primaryColor,
      ),
      body: isLoading ? const LoadingUi() :
      ListView.builder(
          itemCount: requestDates != null ? requestDates.length : 0,
          itemBuilder: (context,i){
            items = requestDates[i];
            return Column(
              children: [
                const SizedBox(height: 5,),
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return UserBankRequestsDetail(req_date:requestDates[i]);
                    }));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0,right: 8),
                    child: Card(
                      color: secondaryColor,
                      elevation: 12,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      ),
                      // shadowColor: Colors.pink,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5.0,bottom: 5),
                        child: ListTile(
                          title: Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Row(
                              children: [
                                const Text("Date: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                Text(items,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            );
          }
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Text("Total"),
        onPressed: (){
          Get.defaultDialog(
            buttonColor: primaryColor,
            title: "Bank Request Deposit Total",
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
