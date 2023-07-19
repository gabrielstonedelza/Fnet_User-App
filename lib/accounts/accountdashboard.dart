import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import '../views/homepage.dart';
import 'editmomoaccounts.dart';

class AccountDashBoard extends StatefulWidget {
  const AccountDashBoard({Key? key}) : super(key: key);

  @override
  _AccountDashBoardState createState() => _AccountDashBoardState();
}

class _AccountDashBoardState extends State<AccountDashBoard> {
  final storage = GetStorage();

  late String mtnEcashNow = "";
  late String physicalServer = "";
  late String mtnEServer = "";


  late String tigoAirtelEcashNow = "";
  late String tigoAirtelPhysicalServer = "";
  late String tigoAirtelEServer = "";


  late String vodafoneEcashNow = "";
  late String vodafonePhysicalServer = "";
  late String vodafoneEServer = "";

  late String accountId = "";
  late String physicalTotalServer = "";
  late String ecashTotalServer = "";
  late String physicalNow = "";
  late String ecashNow = "";
  var items;
  bool isLoading = true;
  late String uToken = "";
  late String username = "";

  fetchAccounts()async{
    const loginUrl = "https://www.fnetghana.xyz/get_user_momo_accounts_started";
    final myLink = Uri.parse(loginUrl);
    final response = await http.get(myLink,headers: {
    "Content-Type": "application/x-www-form-urlencoded",
    "Authorization": "Token $uToken"
    });
    if(response.statusCode == 200){
      final codeUnits = response.body;
      var jsonData = jsonDecode(codeUnits);
      var adminAccounts = jsonData[0];
      setState(() {
        physicalServer = adminAccounts['physical'].toString();
        mtnEServer = adminAccounts['mtn_ecash'].toString();
        tigoAirtelEServer = adminAccounts['tigoairtel_ecash'].toString();
        vodafoneEServer = adminAccounts['vodafone_ecash'].toString();
        ecashTotalServer = adminAccounts['ecash_total'].toString();
        accountId = adminAccounts['id'].toString();
      });
    }
    setState(() {
      isLoading = false;
    });
  }
  closeAccounts() async {
    const accountUrl = "https://www.fnetghana.xyz/post_momo_accounts_closed/";
    final myLink = Uri.parse(accountUrl);
    http.Response response = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "physical": physicalNow,
      "mtn_ecash": mtnEcashNow,
      "tigoairtel_ecash": tigoAirtelEcashNow,
      "vodafone_ecash": vodafoneEcashNow,
    });

    if (response.statusCode == 201) {

      storage.remove("mtnecashnow");
      storage.remove("tigoairtelecashnow");
      storage.remove("tigoairtelecashnow");
      storage.remove("accountcreatedtoday");
      storage.remove("vodafoneecashnow");
      storage.remove("physicalnow");
      storage.remove("ecashnow");
      Get.offAll(() => const HomePage(message: null,));

    } else {
      Get.snackbar("Account", response.body.toString(),
          colorText: defaultTextColor,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackColor);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
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

    if (storage.read("physicalnow") != null) {
      setState(() {
        physicalNow = storage.read("physicalnow").toString();
      });
    }
    if (storage.read("ecashnow") != null) {
      setState(() {
        ecashNow = storage.read("ecashnow").toString();
      });
    }

    if(storage.read("mtnecashnow") != null){
      setState(() {
        mtnEcashNow = storage.read("mtnecashnow").toString();
      });
    }

    if(storage.read("tigoairtelecashnow") != null){
      setState(() {
        tigoAirtelEcashNow = storage.read("tigoairtelecashnow").toString();
      });
    }

    if(storage.read("vodafoneecashnow") != null){
      setState(() {
        vodafoneEcashNow = storage.read("vodafoneecashnow").toString();
      });
    }

    fetchAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Account Dashboard"),
        actions: [
          IconButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return UpdateMomoAccounts(account_id:accountId);
                }));
              },
              icon: const Icon(Icons.edit)
          ),
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
        ) : ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListTile(
                  title: const Text("PHYSICAL"),
                  subtitle: Column(
                    children: [
                      Row(
                        children: [
                          const Text("Placed for processing: "),
                          Text(physicalServer,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.black)),
                        ],
                      ),

                      Row(
                        children: [
                          const Text("Now: "),
                          Text(physicalNow,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.black)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListTile(
                  title: const Text("MTN ECASH"),
                  subtitle: Column(
                    children: [
                      Row(
                        children: [
                          const Text("Placed for processing: "),
                          Text(mtnEServer,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.yellow),),
                        ],
                      ),

                      Row(
                        children: [
                          const Text("Now: "),
                          Text(mtnEcashNow,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.yellow)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListTile(
                  title: const Text("TIgoAirtel ECASH"),
                  subtitle: Column(
                    children: [
                      Row(
                        children: [
                          const Text("Placed for processing: "),
                          Text(tigoAirtelEServer,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.blue),),
                        ],
                      ),

                      Row(
                        children: [
                          const Text("Now: "),
                          Text(tigoAirtelEcashNow,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.blue)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListTile(
                  title: const Text("Vodafone ECASH"),
                  subtitle: Column(
                    children: [
                      Row(
                        children: [
                          const Text("Placed for processing: "),
                          Text(vodafoneEServer,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.red),),
                        ],
                      ),

                      Row(
                        children: [
                          const Text("Now: "),
                          Text(vodafoneEcashNow,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.red)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListTile(
                  title: const Text("Ecash Total"),
                  subtitle: Text(ecashTotalServer,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.green)),
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListTile(
                  title: const Text("Ecash Total Now"),
                  subtitle: Text(ecashNow,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.red))
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: (){
          Get.defaultDialog(
              buttonColor: primaryColor,
              title: "Confirm close",
              middleText: "Are you sure you want to close your accounts?",
              confirm: RawMaterialButton(
                  shape: const StadiumBorder(),
                  fillColor: primaryColor,
                  onPressed: (){
                    closeAccounts();
                    Get.back();
                  }, child: const Text("Yes",style: TextStyle(color: Colors.white),)),
              cancel: RawMaterialButton(
                  shape: const StadiumBorder(),
                  fillColor: primaryColor,
                  onPressed: (){Get.back();},
                  child: const Text("Cancel",style: TextStyle(color: Colors.white),))
          );

        },
        child: const Icon(Icons.upload,color: Colors.white,),
      ),
    );
  }
}
