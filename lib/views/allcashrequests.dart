import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../deposits/cashdepositrequests.dart';
import '../loadingui.dart';
import '../static/app_colors.dart';
import 'cashrequestfromdetails.dart';
import 'cashrequesttodetails.dart';

class AllCashRequests extends StatefulWidget {
  const AllCashRequests({Key? key}) : super(key: key);

  @override
  State<AllCashRequests> createState() => _AllCashRequestsState();
}

class _AllCashRequestsState extends State<AllCashRequests> {
  List allCashRequestsFrom = [];
  List allCashRequestsTo = [];
  List allCashRequestFromDates = [];
  List allCashRequestToDates = [];

  var itemsTo;
  var itemsFrom;
  bool isLoading = true;
  late String uToken = "";
  final storage = GetStorage();
  late String username = "";
  double fromSum = 0.0;
  double toSum = 0.0;

  fetchCashRequestsFrom() async {
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
      allCashRequestsFrom.assignAll(agents);
      for(var i in allCashRequestsFrom){
        fromSum = fromSum + double.parse(i['amount']);
        if(!allCashRequestFromDates.contains(i['date_requested'])){
          allCashRequestFromDates.add(i['date_requested']);
        }
      }
    }
    setState(() {
      isLoading = false;
    });
  }
  fetchCashRequestsTo() async {
    const url = "https://fnetghana.xyz/get_agent2_cash_request_all/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    },);

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      var agents = json.decode(jsonData);
      allCashRequestsTo.assignAll(agents);
      for(var i in allCashRequestsTo){
        toSum = toSum + double.parse(i['amount']);
        if(!allCashRequestToDates.contains(i['date_requested'])){
          allCashRequestToDates.add(i['date_requested']);
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
    fetchCashRequestsFrom();
    fetchCashRequestsTo();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ? const LoadingUi() : DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: (){
                  Get.to(() => const CashDepositRequests());
                },
                icon: const Icon(Icons.add_circle,size:25),
              )
            ],
            backgroundColor: primaryColor,
            bottom: const TabBar(
              tabs: [
                Tab(child: Text("From",style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white)),),
                Tab(child: Text("To",style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white)),),
              ],
            ),
            title: const Text('My Cash Request'),
          ),
          body: TabBarView(
            children: [
              ListView.builder(
                itemCount: allCashRequestFromDates != null ? allCashRequestFromDates.length : 0,
                itemBuilder: (BuildContext context, int index) {
                  itemsFrom = allCashRequestFromDates[index];
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
                            Get.to(() => CashRequestFromDetails(date_requested:allCashRequestFromDates[index]));
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
                itemCount: allCashRequestToDates != null ? allCashRequestToDates.length : 0,
                itemBuilder: (BuildContext context, int index) {
                  itemsTo = allCashRequestToDates[index];
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
                            Get.to(() => CashRequestToDetails(date_requested:allCashRequestFromDates[index]));
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
