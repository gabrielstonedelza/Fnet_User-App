import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class AgentCommission extends StatefulWidget {
  const AgentCommission({Key? key}) : super(key: key);

  @override
  _AgentCommissionState createState() => _AgentCommissionState();
}

class _AgentCommissionState extends State<AgentCommission> {
  late String uToken = "";
  final storage = GetStorage();
  late String username = "";
  late List allMomoDeposits = [];
  late List allMomoWithdraws = [];
  late List commissions = [];
  late List withdrawsCommissions = [];
  double depositSum = 0.0;
  double withdrawSum = 0.0;
  bool isLoading = true;

  fetchUserDepositCommission()async{
    const url = "https://fnetghana.xyz/get_deposit_commission/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allMomoDeposits = json.decode(jsonData);
      commissions.assignAll(allMomoDeposits);
      for(var i in commissions){
        depositSum = depositSum + double.parse(i['agent_commission']);
      }
    }

    setState(() {
      isLoading = false;
      allMomoDeposits = allMomoDeposits;
    });
  }
  fetchUserWithdrawCommission()async{
    const url = "https://fnetghana.xyz/get_withdraw_commission/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allMomoWithdraws = json.decode(jsonData);
      withdrawsCommissions.assignAll(allMomoWithdraws);
      for(var i in withdrawsCommissions){
        withdrawSum = withdrawSum + double.parse(i['agent_commission']);
      }
    }

    setState(() {
      isLoading = false;
      allMomoWithdraws = allMomoWithdraws;
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
    fetchUserDepositCommission();
    fetchUserWithdrawCommission();
  }

  @override
  Widget build(BuildContext context) {
    final totalCommission = depositSum + withdrawSum;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Momo Commission"),
        backgroundColor: primaryColor,
      ),
      body: isLoading ? Column(
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
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: [
                  const Text("Your momo deposit commission"),
                  const SizedBox(height: 20,),
                  Text(depositSum.toString(),style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
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
                  const Text("Your momo withdraws commission"),
                  const SizedBox(height: 20,),
                  Text(withdrawSum.toString(),style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
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
                  const Text("Total commission"),
                  const SizedBox(height: 20,),
                  Text(totalCommission.toString(),style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20,),
        ],
      ),
    );
  }
}
