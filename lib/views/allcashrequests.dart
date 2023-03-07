import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../deposits/cashdepositrequests.dart';
import '../static/app_colors.dart';

class AllCashRequests extends StatefulWidget {
  const AllCashRequests({Key? key}) : super(key: key);

  @override
  State<AllCashRequests> createState() => _AllCashRequestsState();
}

class _AllCashRequestsState extends State<AllCashRequests> {
  List allCashRequestsFrom = [];
  List allCashRequestsTo = [];
  var itemsTo;
  var itemsFrom;
  bool isLoading = true;
  late String uToken = "";
  final storage = GetStorage();
  late String username = "";
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

    }
    setState(() {
      isLoading = false;
      allCashRequestsFrom = allCashRequestsFrom;
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

    }
    setState(() {
      isLoading = false;
      allCashRequestsTo = allCashRequestsTo;
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
      body: isLoading ? const Center(
          child: CircularProgressIndicator(
              strokeWidth: 8,
              color: primaryColor
          )
      ) : DefaultTabController(
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
                itemCount: allCashRequestsFrom != null ? allCashRequestsFrom.length : 0,
                itemBuilder: (BuildContext context, int index) {
                  itemsFrom = allCashRequestsFrom[index];
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
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text("From :",style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  )),
                              const SizedBox(width:10),
                              Text("${itemsFrom['get_agent1_username'].toString().capitalize}",style: const TextStyle(
                              fontWeight: FontWeight.bold,
                                  fontSize: 18,
                              )),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top:18.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Text("To :",style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    )),
                                    const SizedBox(width:10),
                                    Text("${itemsFrom['get_agent2_username'].toString().capitalize}",style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    )),
                                  ],
                                ),
                                const SizedBox(height: 10,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Text("Amount :",style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    )),
                                    const SizedBox(width:10),
                                    Text("₵ ${itemsFrom['amount']}",style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    )),
                                  ],
                                ),
                                const SizedBox(height: 10,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Text("Status :",style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    )),
                                    const SizedBox(width:10),
                                    Text(itemsFrom['request_status'],style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    )),
                                  ],
                                ),
                                const SizedBox(height: 10,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Text("Date/Time: ",style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    )),
                                    Row(

                                      children: [
                                        Text(itemsFrom['date_requested'],style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        )),
                                        const Padding(
                                          padding: EdgeInsets.only(left:8.0,right:8.0),
                                          child: Text("/"),
                                        ),
                                        Text(itemsFrom['time_requested'].toString().split(".").first,style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        )),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },),
              ListView.builder(
                itemCount: allCashRequestsTo != null ? allCashRequestsTo.length : 0,
                itemBuilder: (BuildContext context, int index) {
                  itemsFrom = allCashRequestsTo[index];
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
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text("From :",style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              )),
                              const SizedBox(width:10),
                              Text("${itemsFrom['get_agent1_username'].toString().capitalize}",style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              )),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top:18.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Text("To :",style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    )),
                                    const SizedBox(width:10),
                                    Text("${itemsFrom['get_agent2_username'].toString().capitalize}",style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    )),
                                  ],
                                ),
                                const SizedBox(height: 10,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Text("Amount :",style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    )),
                                    const SizedBox(width:10),
                                    Text("₵ ${itemsFrom['amount']}",style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    )),
                                  ],
                                ),
                                const SizedBox(height: 10,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Text("Status :",style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    )),
                                    const SizedBox(width:10),
                                    Text(itemsFrom['request_status'],style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    )),
                                  ],
                                ),
                                const SizedBox(height: 10,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Text("Date/Time: ",style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    )),
                                    Row(

                                      children: [
                                        Text(itemsFrom['date_requested'],style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        )),
                                        const Padding(
                                          padding: EdgeInsets.only(left:8.0,right:8.0),
                                          child: Text("/"),
                                        ),
                                        Text(itemsFrom['time_requested'].toString().split(".").first,style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        )),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
