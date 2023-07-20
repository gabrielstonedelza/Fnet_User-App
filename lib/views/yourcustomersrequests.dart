import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'approvecustomerrequest.dart';

class UserCustomerRequests extends StatefulWidget {
  const UserCustomerRequests({Key? key}) : super(key: key);

  @override
  _UserCustomerRequestsState createState() => _UserCustomerRequestsState();
}

class _UserCustomerRequestsState extends State<UserCustomerRequests> {
  late List allCustomerRequests = [];
  bool isLoading = true;
  late var items;
  late String uToken = "";
  final storage = GetStorage();
  late String username = "";

  fetchCustomersRequests()async{
    const url = "https://fnetghana.xyz/get_your_customers_request/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allCustomerRequests = json.decode(jsonData);
    }

    setState(() {
      isLoading = false;
      allCustomerRequests = allCustomerRequests;
    });
  }

  void launchWhatsapp({@required number,@required message})async{
    String url = "whatsapp://send?phone=$number&text=$message";
    await canLaunch(url) ? launch(url) : Get.snackbar("Sorry", "Cannot open whatsapp",
        colorText: defaultTextColor,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: snackColor
    );
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
    fetchCustomersRequests();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Column(
          children: const [
            Text("All customer requests"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              fetchCustomersRequests();
            },
          )
        ],
      ),
      body: SafeArea(
          child:
          isLoading ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                    strokeWidth: 5,
                  )
              ),
            ],
          ) : ListView.builder(
              itemCount: allCustomerRequests != null ? allCustomerRequests.length : 0,
              itemBuilder: (context,i){
                items = allCustomerRequests[i];
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
                            onTap: (){
                              if(allCustomerRequests[i]['request_status'] == "Approved"){
                                Get.snackbar("Approve Alert", "You have already approved this request",
                                    colorText: defaultTextColor,
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: snackColor);
                              }
                              else{
                                Navigator.push(context, MaterialPageRoute(builder: (context){
                                  return  DepositDetail(id:allCustomerRequests[i]['id']);
                                }));
                              }
                            },
                            leading: const CircleAvatar(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                child: Icon(Icons.person)
                            ),
                            title: Padding(
                              padding: const EdgeInsets.only(bottom: 15.0),
                              child: Row(
                                children: [
                                  const Text("Name: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                  Text(items['customer_name'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                ],
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text("Amount: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                    Text(items['amount'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                  ],
                                ),
                                const SizedBox(height: 10,),
                                Row(
                                  children: [
                                    const Text("Request Option: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                    Text(items['request_option'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                  ],
                                ),

                                const SizedBox(height: 10,),
                                Row(
                                  children: [
                                    const Text("Phone: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                    Text(items['customer_phone'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                  ],
                                ),
                                const SizedBox(height: 10,),
                                Row(
                                  children: [
                                    const Text("Status: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                    Text(items['request_status'],style: allCustomerRequests[i]['request_status'] == "Approved" ? const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.green) : const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.red),),
                                  ],
                                ),
                                const SizedBox(height: 10,),
                                const Text("Tap to approve",style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold,color: Colors.white),)
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                );
              }
          )
      ),
    );
  }
}
