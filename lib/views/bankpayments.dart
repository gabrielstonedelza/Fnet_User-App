import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fnet_new/sendsms.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import 'homepage.dart';

class BankPayments extends StatefulWidget {
  final bank;
  final amount_delivered;
  final agent;
  const BankPayments({Key? key,this.bank,this.amount_delivered,this.agent}) : super(key: key);

  @override
  _BankPaymentsState createState() => _BankPaymentsState(bank:this.bank,amount_delivered:this.amount_delivered,agent:this.agent);
}

class _BankPaymentsState extends State<BankPayments> {
  final bank;
  final amount_delivered;
  final agent;
  _BankPaymentsState({ required this.bank,required this.amount_delivered,required this.agent});
  bool isLoading = true;
  late String uToken = "";
  final storage = GetStorage();
  late String username = "";
  final SendSmsController sendSms = SendSmsController();
  late String agentPhone = "";
  late String agentName = "";

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController = TextEditingController();
  late final TextEditingController _locationController = TextEditingController();
  late final TextEditingController _leftWithController = TextEditingController();
  late final TextEditingController _leftWithPhoneController = TextEditingController();
  late final TextEditingController _referenceIdController = TextEditingController();

  fetchUser()async{
    final agentUrl = "https://fnetghana.xyz/get_agent/$agent/";
    final agentLink = Uri.parse(agentUrl);
    http.Response res = await http.get(agentLink);
    if(res.statusCode == 200){
      final codeUnits = res.body;
      var jsonData = jsonDecode(codeUnits);
      var myUser = jsonData;
      setState(() {
        agentPhone = myUser['phone'];
        agentName = myUser['username'];
      });
    }
  }

  processBankPayments() async {
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
      "app_version" : "4"
    });
    if(res.statusCode == 201){
      Get.snackbar("Congratulations", "your reference was added",
          colorText: defaultTextColor,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackColor);
      String telnum1 = agentPhone;
      telnum1 = telnum1.replaceFirst("0", '+233');
      String telnum2 = _leftWithPhoneController.text;
      telnum2= telnum2.replaceFirst("0", '+233');
      sendSms.sendMySms(telnum2, "FNET",
          "Hello $agent,reference for your payment GHC$amount_delivered made at $bank is ${_referenceIdController.text}.Thank you");
      sendSms.sendMySms(telnum2, "FNET",
          "Hello ${_leftWithController.text.capitalize},this (${_referenceIdController.text}) reference shows that $agent delivered an amount of GHC$amount_delivered to you at $bank successfully,.Thank you");
      Get.offAll(() => const HomePage(message: null,));
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
    return GestureDetector(
      onTap: (){
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: const Text("Add bank Reference"),
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
                        onTap: (){
                          Get.snackbar("Sorry", "this field is not editable",
                              colorText: defaultTextColor,
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red);
                        },
                        controller: _locationController..text = bank,
                        readOnly: true,
                        cursorColor: primaryColor,
                        cursorRadius: const Radius.elliptical(10, 10),
                        cursorWidth: 10,
                        decoration: InputDecoration(
                            labelText: "Bank",
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
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        onTap: (){
                          Get.snackbar("Sorry", "this field is not editable",
                              colorText: defaultTextColor,
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red);
                        },
                        readOnly: true,
                        controller: _amountController..text = amount_delivered,
                        cursorColor: primaryColor,
                        cursorRadius: const Radius.elliptical(10, 10),
                        cursorWidth: 10,
                        decoration: InputDecoration(
                            labelText: "Amount delivered",
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
                            return "Please enter receiver name";
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
                            return "Please enter receiver's phone";
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
                              title: "Confirm bank reference",
                              middleText: "Are you sure you want to proceed?",
                              confirm: RawMaterialButton(
                                  shape: const StadiumBorder(),
                                  fillColor: primaryColor,
                                  onPressed: (){
                                    processBankPayments();
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
      ),
    );
  }

}
