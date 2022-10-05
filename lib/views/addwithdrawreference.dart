import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fnet_new/sendsms.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import 'bottomnavigation.dart';
import 'homepage.dart';

class AddWithdrawReference extends StatefulWidget {
  final withdrawal_amount;
  final customerphone;
  const AddWithdrawReference({Key? key,this.withdrawal_amount,this.customerphone}) : super(key: key);

  @override
  _AddWithdrawReferenceState createState() => _AddWithdrawReferenceState(withdrawal_amount:this.withdrawal_amount,customerphone:this.customerphone);
}

class _AddWithdrawReferenceState extends State<AddWithdrawReference> {
  final withdrawal_amount;
  final customerphone;
  _AddWithdrawReferenceState({ required this.withdrawal_amount,required this.customerphone});
  bool isLoading = true;
  late String uToken = "";
  final storage = GetStorage();
  late String username = "";
  final SendSmsController sendSms = SendSmsController();
  late String agentPhone = "";
  late String agentName = "";

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController = TextEditingController();
  late final TextEditingController _customerPhoneController = TextEditingController();
  late final TextEditingController _referenceIdController = TextEditingController();

  processWithdrawReference() async {
    const registerUrl = "https://fnetghana.xyz/add_withdraw_reference/";
    final myLink = Uri.parse(registerUrl);
    final res = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "amount": _amountController.text,
      "customer_phone": _customerPhoneController.text,
      "reference_id": _referenceIdController.text,
    });
    if(res.statusCode == 201){
      Get.snackbar("Congratulations", "your reference was added",
          colorText: defaultTextColor,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackColor);
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
          title: const Text("Add Withdraw Reference"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_sharp),
            onPressed: (){
              Get.defaultDialog(
                  buttonColor: primaryColor,
                  title: "Form Error",
                  middleText: "Please enter reference and press save",
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
                        controller: _amountController..text = withdrawal_amount,
                        readOnly: true,
                        cursorColor: primaryColor,
                        cursorRadius: const Radius.elliptical(10, 10),
                        cursorWidth: 10,
                        decoration: InputDecoration(

                            labelText: "Withdrawal amount",
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
                        onTap: (){
                          Get.snackbar("Sorry", "this field is not editable",
                              colorText: defaultTextColor,
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red);
                        },
                        readOnly: true,
                        controller: _customerPhoneController..text = customerphone,
                        cursorColor: primaryColor,
                        cursorRadius: const Radius.elliptical(10, 10),
                        cursorWidth: 10,
                        decoration: InputDecoration(

                            labelText: "Customer's number",
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
                            return "Please enter customer's number";
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
                                    processWithdrawReference();
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
