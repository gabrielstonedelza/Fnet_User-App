import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';


void main() {
  runApp(const MomoTransactions());
}

class MomoTransactions extends StatefulWidget {
  const MomoTransactions({Key? key}) : super(key: key);

  @override
  State<MomoTransactions> createState() => _MomoTransactionsState();
}

class _MomoTransactionsState extends State<MomoTransactions> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _searchFilter = TextEditingController();
  late List searchedDepositCommission = [];
  late List depositResults = [];
  bool isSearching = true;
  var items;
  late String message = "";

  fetchMomoDepositCommission(String searchItem)async{
    final url = "https://fnetghana.xyz/search_agents_momo_deposit_transaction?search=$searchItem";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink);

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      depositResults = json.decode(jsonData);
    }
    else{
      setState(() {
        message = "Sorry nothing found";
      });
    }

    setState(() {
      isSearching = false;
      depositResults = depositResults;
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 1,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: (){
                Get.back();
              },
              icon: const Icon(Icons.arrow_back),
            ),
            bottom: const TabBar(
              tabs: [
                Tab(
                  text: "Momo Deposit",
                ),
              ],
            ),
            title: const Text('Search Transactions'),
            centerTitle: true,
            backgroundColor: primaryColor,
          ),
          body: TabBarView(
            children: [
              Column(
                children: [
                  const SizedBox(height: 10,),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          children: [
                            TextFormField(
                              controller: _searchFilter,
                              cursorColor: primaryColor,
                              cursorRadius: const Radius.elliptical(10, 10),
                              cursorWidth: 10,
                              decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.search,color: secondaryColor,),
                                  labelText: "date(yyyy-mm-dd) or customer number",
                                  labelStyle: const TextStyle(color: secondaryColor),
                                  focusColor: primaryColor,
                                  fillColor: primaryColor,
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: primaryColor, width: 2),
                                      borderRadius: BorderRadius.circular(12)),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12))),
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please field cannot be empty";
                                }
                              },
                            ),
                            const SizedBox(height: 20,),
                            RawMaterialButton(
                              onPressed: () {
                                setState(() {
                                  isSearching = false;
                                });
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                } else {
                                  fetchMomoDepositCommission(_searchFilter.text);
                                }
                              },
                              shape: const StadiumBorder(),
                              elevation: 8,
                              child: const Icon(Icons.search,color: Colors.white,),
                              fillColor: primaryColor,
                              splashColor: defaultColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  isSearching ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 5,
                      color: secondaryColor,
                    ),
                  ) : Expanded(
                    flex: 3,
                    child: ListView.builder(
                        itemCount: depositResults != null ? depositResults.length : 0,
                        itemBuilder: (context,i){
                          items = depositResults[i];
                          return Column(
                            children: [
                              const SizedBox(height: 20,),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0,right: 8),
                                child: Card(
                                  color: secondaryColor,
                                  elevation: 12,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  // shadowColor: Colors.pink,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 18),
                                    child: ListTile(
                                      leading: const CircleAvatar(
                                          backgroundColor: primaryColor,
                                          foregroundColor: Colors.white,
                                          child: Icon(Icons.person)
                                      ),

                                      title: Padding(
                                        padding: const EdgeInsets.only(bottom: 15.0),
                                        child: Row(
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(top:10.0),
                                              child: Text("Name: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top:10.0),
                                              child: Text(items['customer_name'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                            ),
                                          ],
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Text("Phone: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),

                                              Text(items['customer_phone'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text("Network: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),

                                              Text(items['network'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text("Deposit Type: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),

                                              Text(items['type'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text("Amount: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),

                                              Text(items['amount'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text("Time Deposited: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),

                                              Text(items['time_deposited'].toString().split(".").first,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text("Date Deposited: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),

                                              Text(items['date_deposited'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
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
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}