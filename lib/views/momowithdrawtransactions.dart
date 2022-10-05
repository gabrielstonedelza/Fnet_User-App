import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';


void main() {
  runApp(const MomoWithdrawTransactions());
}

class MomoWithdrawTransactions extends StatefulWidget {
  const MomoWithdrawTransactions({Key? key}) : super(key: key);

  @override
  State<MomoWithdrawTransactions> createState() => _MomoWithdrawTransactionsState();
}

class _MomoWithdrawTransactionsState extends State<MomoWithdrawTransactions> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _searchFilter = TextEditingController();

  late List searchedWithdrawCommission = [];
  late List withdrawResults = [];
  bool isSearching = true;
  var items;
  late String message = "";


  fetchMomoWithdrawCommission(String searchItem)async{
    final url = "https://fnetghana.xyz/search_agents_momo_withdraw_transaction?search=$searchItem";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink);

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      withdrawResults = json.decode(jsonData);
    }
    else{
      setState(() {
        message = "Sorry nothing found";
      });
    }

    setState(() {
      isSearching = false;
      withdrawResults = withdrawResults;
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
                  text: "Momo Withdrawal",
                ),

              ],
            ),
            title: const Text('Search transactions'),
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
                                  fetchMomoWithdrawCommission(_searchFilter.text);
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
                        itemCount: withdrawResults != null ? withdrawResults.length : 0,
                        itemBuilder: (context,i){
                          items = withdrawResults[i];
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
                                              const Text("Time of withdrawal: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),

                                              Text(items['time_of_withdrawal'].toString().split(".").first,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text("Date of withdrawal: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),

                                              Text(items['date_of_withdrawal'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
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