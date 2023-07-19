import 'dart:convert';
import 'package:fnet_new/views/userreports.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../static/app_colors.dart';
import '../loadingui.dart';
import 'groupchat.dart';

class AllYourNotifications extends StatefulWidget {
  const AllYourNotifications({Key? key}) : super(key: key);

  @override
  State<AllYourNotifications> createState() => _AllYourNotificationsState();
}

class _AllYourNotificationsState extends State<AllYourNotifications> {
  late List yourNotifications = [];
  bool isLoading = true;
  late String username = "";
  final storage = GetStorage();
  bool hasToken = false;
  late String uToken = "";
  var items;

  getAllNotifications()async{
    const url = "https://fnetghana.xyz/get_all_user_notifications/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });
    if(response.statusCode == 200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      yourNotifications = json.decode(jsonData);
    }
    setState(() {
      isLoading = false;
      yourNotifications = yourNotifications;
      for (var e in yourNotifications) {
        unTriggerNotifications(e["id"]);
      }
    });

  }

  unTriggerNotifications(int id) async {
    final requestUrl = "https://fnetghana.xyz/read_notification/$id/";
    final myLink = Uri.parse(requestUrl);
    final response = await http.put(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
      "Authorization": "Token $uToken"
    }, body: {
      "notification_trigger": "Not Triggered",
      "read": "Read",
    });
    if (response.statusCode == 200) {}
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(storage.read("username") != null){
      setState(() {
        username = storage.read("username");
      });
    }
    if(storage.read("usertoken") != null){
      setState(() {
        hasToken = true;
        uToken = storage.read("usertoken");
      });
    }
    getAllNotifications();
    for (var e in yourNotifications) {
      unTriggerNotifications(e["id"]);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Notifications"),
        backgroundColor: primaryColor,
      ),
      body: isLoading ? const LoadingUi() :
      ListView.builder(
          itemCount: yourNotifications != null ? yourNotifications.length : 0,
          itemBuilder: (context,i){
            items = yourNotifications[i];
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
                    child: ListTile(
                      onTap: (){
                        if(items['notification_title'] == "New group message"){
                          Get.to(() => const GroupChat());
                        }
                        if(items['notification_title'] == "New private message"){
                          // Get.to(() => const GroupChat());
                        }
                        if(items['notification_title'] == "New Report"){
                          Get.to(() => const Reports());
                        }
                        else{

                        }
                      },
                      leading: yourNotifications[i]['read'] == "Not Read" ? const CircleAvatar(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          child: Icon(Icons.notifications)
                      ) : const CircleAvatar(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                          child: Icon(Icons.notifications)
                      ),
                      title: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(items['notification_title'],style: TextStyle(fontWeight: FontWeight.bold,color: yourNotifications[i]['read'] == "Not Read" ? Colors.white : Colors.grey),)
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(items['notification_message'],style: const TextStyle(fontWeight: FontWeight.bold),),
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
