import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fnet_new/sendsms.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:fnet_new/views/customerregistration.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import 'bottomnavigation.dart';
import 'homepage.dart';

class CashAtPayments extends StatefulWidget {
  final cashleftat;
  final amount_delivered;
  final agent;
  const CashAtPayments({Key? key,this.cashleftat,this.amount_delivered,this.agent}) : super(key: key);

  @override
  _CashAtPaymentsState createState() => _CashAtPaymentsState(cashleftat:this.cashleftat,amount_delivered:this.amount_delivered,agent:this.agent);
}

class _CashAtPaymentsState extends State<CashAtPayments> {
  final cashleftat;
  final amount_delivered;
  final agent;
  _CashAtPaymentsState({required this.cashleftat, required this.amount_delivered,required this.agent});
  bool isLoading = true;
  late String uToken = "";
  final storage = GetStorage();
  late String username = "";
  late String adminPhone = "";
  late String agentPhone = "";
  late String agentName = "";

  bool isAtLocation = false;
  bool isBank = false;
  final SendSmsController sendSms = SendSmsController();
  fetchUser()async{
    final agentUrl = "https://fnetghana.xyz/get_agent/$agent/";
    final agentLink = Uri.parse(agentUrl);
    http.Response res = await http.get(agentLink);
    if(res.statusCode == 200){
      final codeUnits = res.body;
      var jsonData = jsonDecode(codeUnits);
      var myUser = jsonData[0];
      setState(() {
        agentPhone = myUser['phone'];
        agentName = myUser['username'];
      });
    }
  }


  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController = TextEditingController();
  late final TextEditingController _locationController = TextEditingController();
  late final TextEditingController _leftWithController = TextEditingController();
  late final TextEditingController _leftWithPhoneController = TextEditingController();
  late final TextEditingController _referenceIdController = TextEditingController();


  processCashAtPayment() async {
    const registerUrl = "https://fnetghana.xyz/make_cash_at_payment/";
    final myLink = Uri.parse(registerUrl);
    final res = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "location":_locationController.text,
      "amount": _amountController.text,
      "left_with": _leftWithController.text,
      "left_with_phone": _leftWithPhoneController.text,
      "reference_id": _referenceIdController.text,
    });
    if(res.statusCode == 201){
      Get.snackbar("Congratulations", "Reference was added",
          colorText: defaultTextColor,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackColor);
      String telnum1 = agentPhone;
      telnum1 = telnum1.replaceFirst("0", '+233');
      String telnum2 = _leftWithPhoneController.text;
      telnum2= telnum2.replaceFirst("0", '+233');
      sendSms.sendMySms(telnum2, "FNET",
          "Hello ${agent},reference for your payment GHC$amount_delivered is ${_referenceIdController.text}.Thank you");
      sendSms.sendMySms(telnum2, "FNET",
          "Hello ${_leftWithController.text.capitalize},this (${_referenceIdController.text}) reference shows that $agent delivered an amount of GHC$amount_delivered to you successfully,.Thank you");
      Get.offAll(() => const MyBottomNavigationBar());
    }
    else{
      Get.snackbar("Request Error", res.body.toString(),
          colorText: defaultTextColor,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackColor);
    }
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
    fetchUser();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_sharp),
          onPressed: (){
            Get.defaultDialog(
              buttonColor: primaryColor,
              title: "Form Error",
              middleText: "Please enter receiver's name,phone,reference and press save",
              confirm: RawMaterialButton(
                  shape: const StadiumBorder(),
                  fillColor: primaryColor,
                  onPressed: (){
                    Get.back();
                  }, child: const Text("close",style: TextStyle(color: Colors.white),)),
            );
          },
        ),
        title: const Text("Make payment"),
      ),
      body: ListView(
        children: [
          const SizedBox(height:30),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: _locationController..text = cashleftat,
                      cursorColor: primaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(

                          labelText: "location",
                          labelStyle: const TextStyle(color: secondaryColor),
                          focusColor: primaryColor,
                          fillColor: primaryColor,
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: primaryColor, width: 2),
                              borderRadius: BorderRadius.circular(12)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if(value!.isEmpty){
                          return "Please enter location";
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: _amountController..text = amount_delivered,
                      cursorColor: primaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(

                          labelText: "Enter amount",
                          labelStyle: const TextStyle(color: secondaryColor),
                          focusColor: primaryColor,
                          fillColor: primaryColor,
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: primaryColor, width: 2),
                              borderRadius: BorderRadius.circular(12)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if(value!.isEmpty){
                          return "Please enter amount";
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: _leftWithController,
                      cursorColor: primaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(

                          labelText: "Enter receiver name",
                          labelStyle: const TextStyle(color: secondaryColor),
                          focusColor: primaryColor,
                          fillColor: primaryColor,
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: primaryColor, width: 2),
                              borderRadius: BorderRadius.circular(12)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if(value!.isEmpty){
                          return "Please enter name of who is receiving";
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: _leftWithPhoneController,
                      cursorColor: primaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(

                          labelText: "Enter receiver's phone",
                          labelStyle: const TextStyle(color: secondaryColor),
                          focusColor: primaryColor,
                          fillColor: primaryColor,
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: primaryColor, width: 2),
                              borderRadius: BorderRadius.circular(12)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if(value!.isEmpty){
                          return "Enter receiver's phone";
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: _referenceIdController,
                      cursorColor: primaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(

                          labelText: "Enter reference id",
                          labelStyle: const TextStyle(color: secondaryColor),
                          focusColor: primaryColor,
                          fillColor: primaryColor,
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: primaryColor, width: 2),
                              borderRadius: BorderRadius.circular(12)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if(value!.isEmpty){
                          return "Please enter reference id";
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20,),
                  RawMaterialButton(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      } else {
                        Get.snackbar("Please wait", "sending your request",
                            colorText: defaultTextColor,
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: snackColor);
                        Get.defaultDialog(
                            buttonColor: primaryColor,
                            title: "Confirm Reference",
                            middleText: "Are you sure you want to proceed?",
                            confirm: RawMaterialButton(
                                shape: const StadiumBorder(),
                                fillColor: primaryColor,
                                onPressed: (){
                                  processCashAtPayment();
                                  Get.back();
                                }, child: const Text("Yes",style: TextStyle(color: Colors.white),)),
                            cancel: RawMaterialButton(
                                shape: const StadiumBorder(),
                                fillColor: primaryColor,
                                onPressed: (){Get.back();},
                                child: const Text("Cancel",style: TextStyle(color: Colors.white),))
                        );
                      }
                    },
                    shape: const StadiumBorder(),
                    elevation: 8,
                    child: const Text(
                      "Save",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white),
                    ),
                    fillColor: primaryColor,
                    splashColor: defaultColor,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
