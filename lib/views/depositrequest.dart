import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fnet_new/deposits/bankdeposit.dart';
import 'package:fnet_new/deposits/expensedeposit.dart';
import 'package:fnet_new/deposits/momodeposit.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:fnet_new/views/searchmomotransactions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../deposits/cashdepositrequests.dart';

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
  late List allPending = [];
  late String username = "";
  bool hasPaymentNotApproved = false;
  bool needApproval = false;
  int notPaidCount = 0;
  late List pendingLists = [];
  late List allUserRequests = [];
  late List amounts = [];
  double sum = 0.0;
  late List allUserPayments = [];
  bool hasUnpaidBankRequests = false;
  late List bankNotPaid = [];
  late List amountsPayments = [];
  double sumPayment = 0.0;

  fetchPaymentTotal()async{
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
        allPending.add(i['payment_status']);
      }
    }
    setState(() {
      isLoading = false;
    });
    if(allPending.contains("Pending")){
      setState(() {
        hasPaymentNotApproved = true;
      });
    }
    for(var pp in allPending){
      if(pp == "Pending"){
        pendingLists.add(pp);
      }
    }
    if(pendingLists.length == 3){
      setState(() {
        notPaidCount = 3;
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
      allUserRequests = json.decode(jsonData);
      amounts.assignAll(allUserRequests);
      for(var i in amounts){
        sum = sum + double.parse(i['amount']);
        bankNotPaid.add(i['deposit_paid']);
      }
    }

    setState(() {
      isLoading = false;
      allUserRequests = allUserRequests;
      if(bankNotPaid.contains("Not Paid")){
        hasUnpaidBankRequests = true;
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
      allUserPayments = json.decode(jsonData);
      amountsPayments.assignAll(allUserPayments);
      for(var i in amountsPayments){
        sumPayment = sumPayment + double.parse(i['amount']);
      }
    }

    setState(() {
      isLoading = false;
      allUserPayments = allUserPayments;
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
    fetchPaymentTotal();
    fetchUserBankRequestsToday();
    fetchUserPayments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Deposit type"),
        backgroundColor: primaryColor,
      ),
      body: isLoading ? const Center(
        child: CircularProgressIndicator(
          strokeWidth: 5,
          color: secondaryColor,
        ),
      ) :  ListView(
        children: [
          const SizedBox(height: 40,),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: (){
                    hasPaymentNotApproved ? Get.snackbar("Payment Error", "You still have unapproved payments pending.Contact admin",
                        colorText: defaultTextColor,
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red
                    ):hasUnpaidBankRequests ? Get.snackbar("Payment Error", "You have not paid your last request,please pay,thank you.",
                        colorText: defaultTextColor,
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red
                    ):
                    Get.to(()=> const BankDeposit());

                  },
                  child: Column(
                    children: [
                      Image.asset("assets/images/bank.png",width: 70,height: 70,),
                      const SizedBox(height: 10,),
                      const Text("Bank Deposit"),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      Image.asset("assets/images/mobile-payment.png",width: 70,height: 70,),
                      const SizedBox(height: 10,),
                      const Text("Momo Deposit"),
                    ],
                  ),
                  onTap: (){
                    hasAccountsToday ? Get.to(()=> const MomoDeposit()): Get.snackbar("Error", "Please add momo accounts for today first",
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
                      Image.asset("assets/images/commission.png",width: 70,height: 70,),
                      const SizedBox(height: 10,),
                      const Text("Momo"),
                      const Text(" Transactions"),
                    ],
                  ),
                  onTap: (){
                    Get.to(()=> const MomoTransactions());
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20,),
          const Divider(),
          const SizedBox(height: 20,),
          Row(
            children: [

              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      Image.asset("assets/images/deposit.png",width: 70,height: 70,),
                      const SizedBox(height: 10,),
                      const Text("Expense Request"),
                    ],
                  ),
                  onTap: (){
                    Get.to(()=> const UserExpenseRequest());
                  },
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      Image.asset("assets/images/cash-on-delivery.png",width: 70,height: 70,),
                      const SizedBox(height: 10,),
                      const Text("Cash Request"),
                    ],
                  ),
                  onTap: (){
                    Get.to(()=> const CashDepositRequests());
                  },
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [

                    ],
                  ),
                  onTap: (){

                  },
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }
}
