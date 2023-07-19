import 'dart:convert';
import 'package:direct_dialer/direct_dialer.dart';
import 'package:flutter/material.dart';
import 'package:fnet_new/deposits/bankdeposit.dart';
import 'package:fnet_new/deposits/expensedeposit.dart';
import 'package:fnet_new/deposits/momodeposit.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:fnet_new/views/searchmomotransactions.dart';
import 'package:fnet_new/views/withdrawal.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../loadingui.dart';
import 'justbank.dart';
import 'justbankwithdrawals.dart';
import 'justmomo.dart';

class Deposits extends StatefulWidget {
  const Deposits({Key? key}) : super(key: key);

  @override
  State<Deposits> createState() => _DepositsState();
}

class _DepositsState extends State<Deposits> {
  final storage = GetStorage();
  bool hasAccountsToday = false;
  bool isLoading = true;
  late String uToken = "";
  late List allPaymentTotal = [];
  late List allCashPaymentTotal = [];
  late List allBankPending = [];
  late List allCashPending = [];
  late String username = "";
  bool hasBankPaymentNotApproved = false;
  bool hasCashPaymentNotApproved = false;
  bool needApproval = false;
  int notPaidBankCount = 0;
  int notPaidCashCount = 0;
  late List pendingBankLists = [];
  late List pendingCashLists = [];
  late List allUserBankRequests = [];
  late List allUserCashRequests = [];
  late List bankAmounts = [];
  late List cashAmounts = [];
  double bankSum = 0.0;
  double cashSum = 0.0;
  late List allUserBankPayments = [];
  late List allUserCashPayments = [];
  bool hasUnpaidBankRequests = false;
  bool hasUnpaidCashRequests = false;
  late List bankNotPaid = [];
  late List cashNotPaid = [];
  late List amountsBankPayments = [];
  late List amountsCashPayments = [];
  double sumBankPayment = 0.0;
  double sumCashPayment = 0.0;

  fetchBankPaymentTotal()async{
    const url = "https://fnetghana.xyz/payment_summary/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allPaymentTotal = json.decode(jsonData);
      for(var i in allPaymentTotal){
        allBankPending.add(i['payment_status']);
      }
    }
    setState(() {
      isLoading = false;
    });
    if(allBankPending.contains("Pending")){
      setState(() {
        hasBankPaymentNotApproved = true;
      });
    }
    for(var pp in allBankPending){
      if(pp == "Pending"){
        pendingBankLists.add(pp);
      }
    }
    if(pendingBankLists.length == 3){
      setState(() {
        notPaidBankCount = 3;
        needApproval = true;
      });
    }
  }
  fetchCashPaymentTotal()async{
    const url = "https://fnetghana.xyz/cash_payment_summary/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allCashPaymentTotal = json.decode(jsonData);
      for(var i in allCashPaymentTotal){
        allCashPending.add(i['payment_status']);
      }
    }
    setState(() {
      isLoading = false;
    });
    if(allCashPending.contains("Pending")){
      setState(() {
        hasCashPaymentNotApproved = true;
      });
    }
    for(var pp in allCashPending){
      if(pp == "Pending"){
        pendingCashLists.add(pp);
      }
    }
    if(pendingCashLists.length == 3){
      setState(() {
        notPaidCashCount = 3;
        needApproval = true;
      });
    }
  }
  fetchUserBankRequestsToday()async{
    const url = "https://fnetghana.xyz/get_bank_total_today/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allUserBankRequests = json.decode(jsonData);
      bankAmounts.assignAll(allUserBankRequests);
      for(var i in bankAmounts){
        bankSum = bankSum + double.parse(i['amount']);
        bankNotPaid.add(i['deposit_paid']);
      }
    }

    setState(() {
      isLoading = false;
      allUserBankRequests = allUserBankRequests;
      if(bankNotPaid.contains("Not Paid")){
        hasUnpaidBankRequests = true;
      }
    });
  }
  fetchUserCashRequestsToday()async{
    const url = "https://fnetghana.xyz/get_cash_requests_for_today/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allUserCashRequests = json.decode(jsonData);
      cashAmounts.assignAll(allUserCashRequests);
      for(var i in cashAmounts){
        cashSum = cashSum + double.parse(i['amount']);
        cashNotPaid.add(i['deposit_paid']);
      }
    }

    setState(() {
      isLoading = false;
      if(cashNotPaid.contains("Not Paid")){
        hasUnpaidCashRequests = true;
      }
    });
  }

  fetchUserPayments()async{
    const url = "https://fnetghana.xyz/get_payment_approved_total/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allUserBankPayments = json.decode(jsonData);
      amountsBankPayments.assignAll(allUserBankPayments);
      for(var i in amountsBankPayments){
        sumBankPayment = sumBankPayment + double.parse(i['amount']);
      }
    }

    setState(() {
      isLoading = false;
      allUserBankPayments = allUserBankPayments;
    });
  }
  fetchUserCashPayments()async{
    const url = "https://fnetghana.xyz/get_cash_payment_approved_total/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allUserCashPayments = json.decode(jsonData);
      amountsCashPayments.assignAll(allUserCashPayments);
      for(var i in amountsCashPayments){
        sumCashPayment = sumCashPayment + double.parse(i['amount']);
      }
    }

    setState(() {
      isLoading = false;
      allUserCashPayments = allUserCashPayments;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(storage.read("accountcreatedtoday") != null){
      setState(() {
        hasAccountsToday = true;
      });
    }
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
    fetchBankPaymentTotal();
    fetchCashPaymentTotal();
    fetchUserBankRequestsToday();
    fetchUserCashRequestsToday();
    fetchUserPayments();
    fetchUserCashPayments();
  }


  // Future<void> dialCashInMtn(String customerNumber,String amount) async {
  //   UssdAdvanced.multisessionUssd(code: "*171*3*1*$customerNumber*$customerNumber*$amount#",subscriptionId: 1);
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bank Transactions"),
        backgroundColor: primaryColor,
      ),
      body: isLoading ? const LoadingUi() :  Column(
        children: [
          const SizedBox(height: 40,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      Image.asset("assets/images/bank.png",width: 70,height: 70,),
                      const SizedBox(height: 10,),
                      const Text("Deposit"),
                    ],
                  ),
                  onTap: (){
                    hasAccountsToday ? Get.to(()=> const BankDeposits()): Get.snackbar("Error", "Please add momo accounts for today first",
                        colorText: defaultTextColor,
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red
                    );
                  },
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      Image.asset("assets/images/bank.png",width: 70,height: 70,),
                      const SizedBox(height: 10,),
                      const Text("Withdrawal"),
                    ],
                  ),
                  onTap: (){
                    hasAccountsToday ? Get.to(()=> const WithDrawal()): Get.snackbar("Error", "Please add momo accounts for today first",
                        colorText: defaultTextColor,
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red
                    );

                  },
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
