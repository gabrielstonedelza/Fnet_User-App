import 'dart:convert';
import 'package:fnet_new/static/app_colors.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class MyCashPaymentDetails extends StatefulWidget {
  final date_created;
  const MyCashPaymentDetails({Key? key,required this.date_created}) : super(key: key);

  @override
  State<MyCashPaymentDetails> createState() => _MyCashPaymentDetailsState(date_created:this.date_created);
}

class _MyCashPaymentDetailsState extends State<MyCashPaymentDetails> {
  final date_created;
  _MyCashPaymentDetailsState({required this.date_created});
  List allCashPayments = [];
  List allCashPaymentsDates = [];
  var itemsFrom;
  bool isLoading = true;
  late String uToken = "";
  final storage = GetStorage();
  late String username = "";
  double sum = 0.0;

  Future<void> fetchAllMyCashPayments() async {
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
      allCashPaymentsDates.assignAll(agents);
      for(var i in allCashPaymentsDates){

        if(i['date_created'] == date_created){
          allCashPayments.add(i);
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
    fetchAllMyCashPayments();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Cash payments for $date_created"),
          backgroundColor:primaryColor
      ),
      body: isLoading ? const Center(
        child: CircularProgressIndicator(),
      ) : ListView.builder(
        itemCount: allCashPayments != null ? allCashPayments.length : 0,
        itemBuilder: (context,index){
          itemsFrom = allCashPayments[index];
          return Card(
            elevation: 12,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Row(
                  children: [
                    const Text("Agent: ",style:TextStyle(fontWeight: FontWeight.bold)),
                    Text(itemsFrom['agent_username'],style:const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Row(
                        children: [
                          const Text("Mode of payment 1: ",style:TextStyle(fontWeight: FontWeight.bold)),
                          Text(itemsFrom['mode_of_payment1'],style:const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  itemsFrom['mode_of_payment2'] != "Select mode of payment" ? Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Row(
                        children: [
                          const Text("Mode of payment 2: ",style:TextStyle(fontWeight: FontWeight.bold)),
                          Text(itemsFrom['mode_of_payment2'],style:const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ) : Container(),
                    itemsFrom['cash_at_location1'] != "Please select cash at location" ?  Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Row(
                        children: [
                          const Text("Cash @ location 1: ",style:TextStyle(fontWeight: FontWeight.bold)),
                          Text(itemsFrom['cash_at_location1'],style:const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ):Container(),
                    itemsFrom['cash_at_location2'] != "Please select cash at location" ? Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Row(
                        children: [
                          const Text("Cash @ location 2: ",style:TextStyle(fontWeight: FontWeight.bold)),
                          Text(itemsFrom['cash_at_location2'],style:const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ):Container(),
                    itemsFrom['bank1'] != "Select bank" ?  Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Row(
                        children: [
                          const Text("Bank 1: ",style:TextStyle(fontWeight: FontWeight.bold)),
                          Text(itemsFrom['bank1'],style:const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ):Container(),
                    itemsFrom['bank2'] != "Select bank" ? Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Row(
                        children: [
                          const Text("Bank 2: ",style:TextStyle(fontWeight: FontWeight.bold)),
                          Text(itemsFrom['bank2'],style:const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ):Container(),
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
                          const Text("Reference 1 : ",style:TextStyle(fontWeight: FontWeight.bold)),
                          Text(itemsFrom['transaction_id1'],style:const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    itemsFrom['transaction_id2'] != "" ? Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Row(
                        children: [
                          const Text("Reference 2 : ",style:TextStyle(fontWeight: FontWeight.bold)),
                          Text(itemsFrom['transaction_id2'],style:const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ):Container(),
                    Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Row(
                        children: [
                          const Text("Date : ",style:TextStyle(fontWeight: FontWeight.bold)),
                          Text(itemsFrom['date_created'],style:const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Row(
                        children: [
                          const Text("Time : ",style:TextStyle(fontWeight: FontWeight.bold)),
                          Text(itemsFrom['time_created'].toString().split(".").first,style:const TextStyle(fontWeight: FontWeight.bold)),
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
