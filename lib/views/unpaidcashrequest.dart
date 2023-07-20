import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../loadingui.dart';
import 'makecashpayment.dart';

class UnpaidCashRequests extends StatefulWidget {
  const UnpaidCashRequests({Key? key}) : super(key: key);

  @override
  _UnpaidCashRequestsState createState() => _UnpaidCashRequestsState();
}

class _UnpaidCashRequestsState extends State<UnpaidCashRequests> {
  final storage = GetStorage();
  bool isLoading = true;
  late String uToken = "";
  late List cashRequestsNotPaid = [];
  late String username = "";
  var items;

  fetchUserCashRequestsToday()async{
    const url = "https://fnetghana.xyz/get_agents_unpaid_cash_deposits/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode == 200){

      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      cashRequestsNotPaid = json.decode(jsonData);

    }

    setState(() {
      isLoading = false;
      cashRequestsNotPaid = cashRequestsNotPaid;
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(storage.read("usertoken") != null){
      setState(() {
        uToken = storage.read("usertoken");
      });
    }
    if(storage.read("username") != null){
      setState(() {
        username = storage.read("username");
      });
    }
    fetchUserCashRequestsToday();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unpaid Cash Requests"),
        backgroundColor: primaryColor,
      ),
      body: isLoading ? const LoadingUi() :
      ListView.builder(
          itemCount: cashRequestsNotPaid != null ? cashRequestsNotPaid.length : 0,
          itemBuilder: (context,i){
            items = cashRequestsNotPaid[i];
            return Column(
              children: [
                const SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0,right: 8),
                  child: Card(
                    elevation: 12,
                    color: secondaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    // shadowColor: Colors.pink,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 18.0,bottom: 18),
                      child: ListTile(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context){
                            return  MakeCashPayment(id:cashRequestsNotPaid[i]['id'],depositType:"Bank",amount:cashRequestsNotPaid[i]['amount'],agent1:cashRequestsNotPaid[i]['agent1'].toString(),agent2:cashRequestsNotPaid[i]['agent2'].toString());
                          }));
                        },
                        title: Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: Row(
                              children: [
                                const Text("Agent: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                Text(items['get_agent1_username'].toString().toUpperCase(),style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                              ],
                            )
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: Row(
                                  children: [
                                    const Text("Agent 2: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                    Text(items['get_agent2_username'].toString().toUpperCase(),style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                  ],
                                )
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Row(
                                children: [
                                  const Text("Amount: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                  Text(items['amount'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Row(
                                children: [
                                  const Text("Request Paid: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                  Text(items['request_paid'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                ],
                              ),
                            ),

                            Row(
                              children: [
                                const Text("Date Requested: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                Text(items['date_requested'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                              ],
                            ),
                            Row(
                              children: [
                                const Text("Time Requested: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                Text(items['time_requested'].toString().split(".").first,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
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
      ),
    );
  }
}
