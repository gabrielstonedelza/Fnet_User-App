import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class UserAccountTotal extends StatefulWidget {
  const UserAccountTotal({Key? key}) : super(key: key);

  @override
  _UserAccountTotalState createState() => _UserAccountTotalState();
}

class _UserAccountTotalState extends State<UserAccountTotal> {
  late List allUserRequests = [];
  bool isLoading = true;
  late String uToken = "";
  final storage = GetStorage();
  late String username = "";
  late var items;
  late double cashDepositTotal = 0;
  late double bankDepositTotal = 0;
  late double paymentTotal = 0;
  late List allCashDepoTotal = [];
  late List allBankDepoTotal = [];
  late List allDepoAmountTotal = [];
  late List allPaymentTotal = [];
  late double depoPaymentDiff = 0;
  late double BankTotal = 0;
  bool paymentFull = false;
  late double fullPaymentTotal = 0;

  fetchCashDepositTotal()async{
    const url = "https://fnetghana.xyz/get_cash_total_today/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allCashDepoTotal = json.decode(jsonData);
      for(var i in allCashDepoTotal){
        cashDepositTotal = cashDepositTotal + double.parse(i['amount']);
      }
    }
    setState(() {
      isLoading = false;
    });
  }
  fetchBankDepositTotal()async{
    const url = "https://fnetghana.xyz/get_bank_total_today/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allBankDepoTotal = json.decode(jsonData);
      for(var i in allBankDepoTotal){
        bankDepositTotal = bankDepositTotal + double.parse(i['amount']);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  fetchPaymentTotal()async{
    const url = "https://fnetghana.xyz/get_payment_approved_total/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allPaymentTotal = json.decode(jsonData);
      for(var i in allPaymentTotal){
        fullPaymentTotal = double.parse(i['amount']);
        paymentTotal = paymentTotal.roundToDouble() + fullPaymentTotal.roundToDouble();
      }
    }
    setState(() {
      isLoading = false;
    });
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
    fetchCashDepositTotal();
    fetchBankDepositTotal();
    fetchPaymentTotal();
  }
  @override
  Widget build(BuildContext context) {
    BankTotal = bankDepositTotal.roundToDouble();
    depoPaymentDiff = BankTotal - paymentTotal;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Column(
          children: const [
            Text("Account Total"),
          ],
        ),
      ),
      body: SafeArea(
          child:
          isLoading ? const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
                strokeWidth: 5,
              )
          ) : Center(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const SizedBox(height: 20,),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      children: [
                        const Text("Your bank request total"),
                        const SizedBox(height: 20,),
                        Text(bankDepositTotal.toString(),style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      children: [
                        const Text("Your payment total"),
                        const SizedBox(height: 30,),
                        Text(paymentTotal.toString(),style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30,),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      children: [
                        const Text("Balance"),
                        const SizedBox(height: 20,),
                        Text(depoPaymentDiff.toString(),style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30,),

              ],
            ),
          )
      ),
    );
  }
}
