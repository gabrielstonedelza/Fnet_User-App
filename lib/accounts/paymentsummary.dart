import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:fnet_new/views/userpaymentdetail.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import '../loadingui.dart';

class PaymentRequestSummary extends StatefulWidget {
  const PaymentRequestSummary({Key? key}) : super(key: key);

  @override
  _PaymentRequestSummaryState createState() => _PaymentRequestSummaryState();
}

class _PaymentRequestSummaryState extends State<PaymentRequestSummary> {

  late String username = "";
  final storage = GetStorage();
  bool hasToken = false;
  late String uToken = "";
  late List allUserPayments = [];
  var items;
  bool isLoading = true;
  late List amounts = [];
  late List paymentDates = [];
  double sum = 0.0;

  fetchAllUserPayments()async{
    const url = "https://fnetghana.xyz/user_total_payments/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allUserPayments = json.decode(jsonData);
      amounts = allUserPayments;
      for(var i in amounts){
        sum = sum + double.parse(i['amount']);
        if(!paymentDates.contains(i['date_created'])){
          paymentDates.add(i['date_created']);
        }
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
    fetchAllUserPayments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Summary"),
        backgroundColor: primaryColor,
      ),
      body: isLoading ? const LoadingUi()
          : ListView.builder(
          itemCount: paymentDates != null ? paymentDates.length : 0,
          itemBuilder: (context,i){
            items = paymentDates[i];
            return Column(
              children: [
                const SizedBox(height: 5,),
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return UserPaymentDetail(paydate:paymentDates[i]);
                    }));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0,right: 8),
                    child: Card(
                      color: secondaryColor,
                      elevation: 12,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      ),
                      // shadowColor: Colors.pink,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5.0,bottom: 5),
                        child: ListTile(
                          title: Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Row(
                              children: [
                                const Text("Date: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white)),
                                Text(items,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                              ],
                            ),
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
        child: const Text("Total"),
        onPressed: (){
          Get.defaultDialog(
            buttonColor: primaryColor,
            title: "Payment Total",
            middleText: "$sum",
            confirm: RawMaterialButton(
                shape: const StadiumBorder(),
                fillColor: primaryColor,
                onPressed: (){
                  Get.back();
                }, child: const Text("Close",style: TextStyle(color: Colors.white),)),
          );

        },
      ),
    );
  }
}
