import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fnet_new/accounts/tigodepositdetail.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';


class TigoDepositSummary extends StatefulWidget {
  const TigoDepositSummary({Key? key}) : super(key: key);

  @override
  _TigoDepositSummaryState createState() => _TigoDepositSummaryState();
}

class _TigoDepositSummaryState extends State<TigoDepositSummary> {

  late String username = "";
  final storage = GetStorage();
  bool hasToken = false;
  late String uToken = "";
  late List allMomoDeposits = [];
  var items;
  bool isLoading = true;
  late List amounts = [];
  late List bankAmounts = [];
  late List tigoDepositDates = [];
  double sum = 0.0;

  fetchAllTigoDeposits()async{
    const url = "https://fnetghana.xyz/get_user_tigo_deposits_summary/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allMomoDeposits = json.decode(jsonData);
      amounts = allMomoDeposits;
      for(var i in amounts){
        sum = sum + double.parse(i['amount']);
        if(!tigoDepositDates.contains(i['date_deposited'])){
          tigoDepositDates.add(i['date_deposited']);
        }
      }
    }

    setState(() {
      isLoading = false;
      tigoDepositDates = tigoDepositDates;
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
    fetchAllTigoDeposits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tigo Deposit Summary"),
        backgroundColor: primaryColor,
      ),
      body: isLoading ? const Center(
        child: CircularProgressIndicator(
          strokeWidth: 5,
          color: secondaryColor,
        ),
      ) :
      ListView.builder(
          itemCount: tigoDepositDates != null ? tigoDepositDates.length : 0,
          itemBuilder: (context,i){
            items = tigoDepositDates[i];
            return Column(
              children: [
                const SizedBox(height: 20,),
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return TigoDepositSummaryDetail(deposit_date:tigoDepositDates[i]);
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
                        padding: const EdgeInsets.only(top: 18.0,bottom: 18),
                        child: ListTile(
                          title: Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
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
