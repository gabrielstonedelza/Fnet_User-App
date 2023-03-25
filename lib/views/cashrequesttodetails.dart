import 'dart:convert';
import 'package:fnet_new/static/app_colors.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class CashRequestToDetails extends StatefulWidget {
  final date_requested;
  const CashRequestToDetails({Key? key,required this.date_requested}) : super(key: key);

  @override
  State<CashRequestToDetails> createState() => _CashRequestToDetailsState(date_requested:this.date_requested);
}

class _CashRequestToDetailsState extends State<CashRequestToDetails> {
  final date_requested;
  _CashRequestToDetailsState({required this.date_requested});
  List allCashRequestsTo = [];
  List allCashRequestToDates = [];
  var itemsFrom;
  bool isLoading = true;
  late String uToken = "";
  final storage = GetStorage();
  late String username = "";
  double sum = 0.0;

  fetchCashRequestsTo() async {
    const url = "https://fnetghana.xyz/get_agent1_cash_request_all/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    },);

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      var agents = json.decode(jsonData);
      allCashRequestToDates.assignAll(agents);
      for(var i in allCashRequestToDates){

        if(i['date_requested'] == date_requested){
          allCashRequestsTo.add(i);
          sum = sum + double.parse(i['amount']);
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
    fetchCashRequestsTo();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Cash Requests for $date_requested"),
          backgroundColor:primaryColor
      ),
      body: isLoading ? const Center(
        child: CircularProgressIndicator(),
      ) : ListView.builder(
        itemCount: allCashRequestsTo != null ? allCashRequestsTo.length : 0,
        itemBuilder: (context,index){
          itemsFrom = allCashRequestsTo[index];
          return Card(
            elevation: 12,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Row(
                  children: [
                    const Text("Agent1 : ",style:TextStyle(fontWeight: FontWeight.bold)),
                    Text(itemsFrom['get_agent1_username'],style:const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Row(
                        children: [
                          const Text("Agent2 : ",style:TextStyle(fontWeight: FontWeight.bold)),
                          Text(itemsFrom['get_agent2_username'],style:const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Row(
                        children: [
                          const Text("Amount : ",style:TextStyle(fontWeight: FontWeight.bold)),
                          Text(itemsFrom['amount'],style:const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Row(
                        children: [
                          const Text("Status : ",style:TextStyle(fontWeight: FontWeight.bold)),
                          Text(itemsFrom['request_status'],style:const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Row(
                        children: [
                          const Text("Paid : ",style:TextStyle(fontWeight: FontWeight.bold)),
                          Text(itemsFrom['request_paid'],style:const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Row(
                        children: [
                          const Text("Date : ",style:TextStyle(fontWeight: FontWeight.bold)),
                          Text(itemsFrom['date_requested'],style:const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Row(
                        children: [
                          const Text("Time : ",style:TextStyle(fontWeight: FontWeight.bold)),
                          Text(itemsFrom['time_requested'].toString().split(".").first,style:const TextStyle(fontWeight: FontWeight.bold)),
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
