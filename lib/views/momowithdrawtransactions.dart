import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../static/app_colors.dart';
import 'cashrequestfromdetails.dart';
import 'cashrequesttodetails.dart';

class MomoWithdrawTransactions extends StatefulWidget {
  const MomoWithdrawTransactions({Key? key}) : super(key: key);

  @override
  State<MomoWithdrawTransactions> createState() => _MomoWithdrawTransactionsState();
}

class _MomoWithdrawTransactionsState extends State<MomoWithdrawTransactions> {
  late List allMomoDeposits = [];
  List allCashInForCustomers = [];
  List allCashInForCustomersDates = [];
  List allCashInForAgents = [];
  List allCashInForAgentsDates = [];
  List allCashInForMerchants = [];
  List allCashInForMerchantsDates = [];

  var itemsTo;
  var itemsFrom;
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
      for(var i in allCashInForCustomers){
        if(i['type'] == "Customer"){
          if(!allCashInForCustomers.contains(i)){
            allCashInForCustomers.add(i);
          }
        }
        if(i['type'] == "Merchant"){
          if(!allCashInForMerchants.contains(i)){
            allCashInForMerchants.add(i);
          }
        }
        if(i['type'] == "Agent"){
          if(!allCashInForAgents.contains(i)){
            allCashInForAgents.add(i);
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
      body: isLoading ? const Center(
          child: CircularProgressIndicator(
              strokeWidth: 8,
              color: primaryColor
          )
      ) : DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: primaryColor,
            bottom: const TabBar(
              tabs: [
                Tab(child: Text("Customers",style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white)),),
                Tab(child: Text("Agents",style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white)),),
                Tab(child: Text("Merchants",style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white)),),
              ],
            ),
            title: const Text('Momo Cash In Transactions'),
          ),
          body: TabBarView(
            children: [
              ListView.builder(
                itemCount: allCashInForCustomersDates != null ? allCashInForCustomersDates.length : 0,
                itemBuilder: (BuildContext context, int index) {
                  itemsFrom = allCashInForCustomersDates[index];
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
                            Get.to(() => CashRequestFromDetails(date_requested:allCashInForCustomersDates[index]));
                          },
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text("Date :",style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              )),
                              const SizedBox(width:10),
                              Text(itemsFrom,style: const TextStyle(
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
                  itemsTo = allCashInForAgentsDates[index];
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
                            Get.to(() => CashRequestToDetails(date_requested:allCashInForCustomersDates[index]));
                          },
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text("Date :",style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              )),
                              const SizedBox(width:10),
                              Text(itemsTo,style: const TextStyle(
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
