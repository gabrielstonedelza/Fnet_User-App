import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../loadingui.dart';
import '../static/app_colors.dart';
import 'momocashinagentsdetails.dart';
import 'momocashincustomerdetail.dart';
import 'momocashinmerchantdetails.dart';

class MomoDepositsTransactions extends StatefulWidget {
  const MomoDepositsTransactions({Key? key}) : super(key: key);

  @override
  State<MomoDepositsTransactions> createState() => _MomoDepositsTransactionsState();
}

class _MomoDepositsTransactionsState extends State<MomoDepositsTransactions> {
  late List allMomoDeposits = [];
  List allCashInForCustomers = [];
  List allCashInForCustomersDates = [];
  List allCashInForAgents = [];
  List allCashInForAgentsDates = [];
  List allCashInForMerchants = [];
  List allCashInForMerchantsDates = [];

  var customersItem;
  var agentItems;
  var merchantItems;
  bool isLoading = true;
  late String uToken = "";
  final storage = GetStorage();
  late String username = "";
  double fromSum = 0.0;
  double toSum = 0.0;

  fetchAllMyMomoDeposits() async {
    const url = "https://fnetghana.xyz/get_user_momo_deposits/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    },);

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      var agents = json.decode(jsonData);
      allMomoDeposits.assignAll(agents);
      for(var i in allMomoDeposits){
        if(i['type'] == "Customer"){
          if(!allCashInForCustomers.contains(i)){
            allCashInForCustomers.add(i);
            for(var t in allCashInForCustomers){
              if(!allCashInForCustomersDates.contains(t['date_deposited'])){
                allCashInForCustomersDates.add(t['date_deposited']);
              }
            }
          }
        }
        if(i['type'] == "Merchant"){
          if(!allCashInForMerchants.contains(i)){
            allCashInForMerchants.add(i);
            for(var t in allCashInForMerchants){
              if(!allCashInForMerchantsDates.contains(t['date_deposited'])){
                allCashInForMerchantsDates.add(t['date_deposited']);
              }
            }
          }
        }
        if(i['type'] == "Agent"){
          if(!allCashInForAgents.contains(i)){
            allCashInForAgents.add(i);
            for(var t in allCashInForAgents){
              if(!allCashInForAgentsDates.contains(t['date_deposited'])){
                allCashInForAgentsDates.add(t['date_deposited']);
              }
            }
          }
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
    fetchAllMyMomoDeposits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ? const LoadingUi() : DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: primaryColor,
            bottom: TabBar(
              tabs: [
                // Tab(child: Column(
                //   children: [
                //     const Text("Customers",style: TextStyle(
                //         fontWeight: FontWeight.bold,
                //         fontSize: 15,
                //         color: Colors.white)),
                //     Text("(${allCashInForCustomers.length})",style: const TextStyle(
                //         fontWeight: FontWeight.bold,
                //         fontSize: 15,
                //         color: Colors.white))
                //   ],
                // ),),
                Tab(child: Column(
                  children: [
                    const Text("Agents",style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white)),
                    Text("(${allCashInForAgents.length})",style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white)),
                  ],
                ),),
                Tab(child: Column(
                  children: [
                    const Text("Merchants",style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white)),
                    Text("(${allCashInForMerchants.length})",style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white)),
                  ],
                ),),
              ],
            ),
            title: const Text('Momo Pay To Transactions'),
          ),
          body: TabBarView(
            children: [
              ListView.builder(
                itemCount: allCashInForCustomersDates != null ? allCashInForCustomersDates.length : 0,
                itemBuilder: (BuildContext context, int index) {
                  customersItem = allCashInForCustomersDates[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 12,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          onTap: (){
                            Get.to(() => MomoCashInCustomersDetails(date_deposited:allCashInForCustomersDates[index],customersCashIn:allCashInForCustomers));
                          },
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text("Date :",style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              )),
                              const SizedBox(width:10),
                              Text(customersItem,style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },),
              ListView.builder(
                itemCount: allCashInForAgentsDates != null ? allCashInForAgentsDates.length : 0,
                itemBuilder: (BuildContext context, int index) {
                  agentItems = allCashInForAgentsDates[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 12,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          onTap: (){
                            Get.to(() => MomoCashInAgentsDetails(date_deposited:allCashInForCustomersDates[index],agentCashIn:allCashInForAgents));
                          },
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text("Date :",style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              )),
                              const SizedBox(width:10),
                              Text(agentItems,style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },),
              ListView.builder(
                itemCount: allCashInForMerchantsDates != null ? allCashInForMerchantsDates.length : 0,
                itemBuilder: (BuildContext context, int index) {
                  merchantItems = allCashInForMerchantsDates[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 12,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          onTap: (){
                            Get.to(() => MomoCashInMerchantsDetails(date_deposited:allCashInForCustomersDates[index],merchantCashIn:allCashInForMerchants));
                          },
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text("Date :",style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              )),
                              const SizedBox(width:10),
                              Text(merchantItems,style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },),
            ],
          ),
        ),
      ),
    );
  }
}
