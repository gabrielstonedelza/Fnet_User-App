import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:fnet_new/accounts/userbankpaymentdetail.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import 'bankpayments.dart';

class UserBankPayments extends StatefulWidget {
  const UserBankPayments({Key? key}) : super(key: key);

  @override
  State<UserBankPayments> createState() => _UserBankPaymentsState();
}

class _UserBankPaymentsState extends State<UserBankPayments> {
  late String uToken = "";
  final storage = GetStorage();
  late String username = "";
  var items;
  late List paymentDates = [];
  late List paymentTimes = [];
  late List amounts = [];
  late List allUserPayments = [];
  double sum = 0.0;
  bool isLoading = true;

  fetchUserBankPayments()async{
    const url = "https://fnetghana.xyz/get_all_my_data_at_bank/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
    "Content-Type": "application/x-www-form-urlencoded",
    "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){

      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allUserPayments = json.decode(jsonData);
      // amounts.assignAll(allUserPayments);
    }else{
      if (kDebugMode) {
        print(response.body);
      }
    }

    setState(() {
      isLoading = false;
      paymentDates = paymentDates;
    });
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
    fetchUserBankPayments();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Your bank payments"),
      ),
      body: isLoading ? const Center(
          child: CircularProgressIndicator(
            color: primaryColor,
            strokeWidth: 5,
          )
      ) : ListView.builder(
          itemCount: allUserPayments != null ? allUserPayments.length : 0,
          itemBuilder: (context,i){
            items = allUserPayments[i];
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
                      padding: const EdgeInsets.only(top: 8.0,bottom: 8),
                      child: ListTile(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context){
                            return UserBankPaymentDetails(id:allUserPayments[i]['id'].toString());
                          }));
                        },
                        title: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Text("Date: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white)),
                                  Text(items['date_added'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                ],
                              ),
                              const SizedBox(height: 10,),
                              Row(
                                children: [
                                  const Text("Time: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white)),
                                  Text(items['time_added'].toString().split(".").first,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            );
          }
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: (){
          Get.to(() => const MyBankPayments());
        },
        child: const Icon(Icons.add,color: Colors.white,),
      ),
    );
  }

}
