import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:fnet_new/views/searchcustomers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../loadingui.dart';
import 'editcustomer.dart';

class UserCustomers extends StatefulWidget {
  const UserCustomers({Key? key}) : super(key: key);

  @override
  _UserCustomersState createState() => _UserCustomersState();
}

class _UserCustomersState extends State<UserCustomers> {
  late List allCustomers = [];
  bool isLoading = true;
  late var items;
  late String uToken = "";
  final storage = GetStorage();
  late String username = "";

  fetchCustomers()async{
    const url = "https://fnetghana.xyz/user_customers/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allCustomers = json.decode(jsonData);
    }

    setState(() {
      isLoading = false;
      allCustomers = allCustomers;
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
    fetchCustomers();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Column(
          children: [
            Text("All Your Customers"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              fetchCustomers();
            },
          )
        ],
      ),
      body: SafeArea(
          child:
          isLoading ? const LoadingUi() : ListView.builder(
              itemCount: allCustomers != null ? allCustomers.length : 0,
              itemBuilder: (context,i){
                items = allCustomers[i];
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
                              Navigator.push(context, MaterialPageRoute(builder: (context){
                                return UpdateCustomersDetails(id:allCustomers[i]['id']);
                              }));
                              // String telnum = allCustomers[i]['phone'];
                              // telnum = telnum.replaceFirst("0", '+233');
                              // launchWhatsapp(message: "Hello", number: telnum);
                            },
                            trailing: const Icon(Icons.edit,color: Colors.white,),
                            leading: const CircleAvatar(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                child: Icon(Icons.person)
                            ),
                            title: Padding(
                              padding: const EdgeInsets.only(bottom: 15.0),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    const Text("Name: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                    Text(items['name'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                  ],
                                ),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text("Phone: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),

                                    Text(items['phone'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                  ],
                                ),
                                const SizedBox(height: 10,),
                                const Text("Tap to edit customers details",style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold,color: Colors.white),)
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: secondaryColor,
        child: const Icon(Icons.search,color: Colors.white,),
        onPressed: (){
          Get.to(()=> const SearchCustomers());
        },
      ),
    );
  }
}
