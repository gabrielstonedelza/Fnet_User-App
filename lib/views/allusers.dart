import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fnet_new/views/privatechat.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../static/app_colors.dart';

class AllUsers extends StatefulWidget {
  const AllUsers({Key? key}) : super(key: key);

  @override
  _AllUsersState createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers> {
  late List allUsers = [];
  bool isLoading = true;
  late var items;
  late List customerNumber = [];
  late String username = "";
  String profileId = "";
  final storage = GetStorage();
  bool hasToken = false;
  late String uToken = "";

  fetchAllUsers()async{
    const url = "https://fnetghana.xyz/all_agents/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink,headers: {"Authorization": "Token $uToken"});

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allUsers = json.decode(jsonData);
      for(var i in customerNumber){
        customerNumber.add(i['phone']);
      }
    }

    setState(() {
      isLoading = false;
      allUsers = allUsers;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (storage.read("username") != null) {
      setState(() {
        username = storage.read("username");
      });
    }
    if (storage.read("usertoken") != null) {
      setState(() {
        hasToken = true;
        uToken = storage.read("usertoken");
      });
    }
    if (storage.read("profile_id") != null) {
      setState(() {
        hasToken = true;
        profileId = storage.read("profile_id");
      });
    }
    fetchAllUsers();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("All Users"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              fetchAllUsers();
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
              itemCount: allUsers != null ? allUsers.length : 0,
              itemBuilder: (context,i){
                items = allUsers[i];
                return Column(
                  children: [
                    const SizedBox(height: 10,),
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
                          padding: const EdgeInsets.only(bottom: 5),
                          child: ListTile(
                            onTap: (){
                              // String telnum = allUsers[i]['phone'];
                              // telnum = telnum.replaceFirst("0", '+233');
                              // launchWhatsapp(message: "Hello", number: telnum);
                              Get.to(()=> PrivateChat(receiverUserName:allUsers[i]['username'],receiverId:allUsers[i]['id'].toString()));
                              // print(allUsers[i]['id'].toString());
                            },
                            leading: const CircleAvatar(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                child: Icon(Icons.person)
                            ),
                            title: Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Text(items['username'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(items['company_name'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5,)
                  ],
                );
              }
          )
      ),

    );
  }
}
