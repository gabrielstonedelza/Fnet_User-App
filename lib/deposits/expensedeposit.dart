import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:fnet_new/views/bottomnavigation.dart';
import 'package:fnet_new/views/customerregistration.dart';
import 'package:fnet_new/views/homepage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../sendsms.dart';

class UserExpenseRequest extends StatefulWidget {
  const UserExpenseRequest({Key? key}) : super(key: key);

  @override
  _UserExpenseRequestState createState() => _UserExpenseRequestState();
}

class _UserExpenseRequestState extends State<UserExpenseRequest> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reasonController = TextEditingController();
  late final TextEditingController _amount = TextEditingController();

  bool isLoading = true;
  late String uToken = "";
  final storage = GetStorage();
  late String username = "";

  late String adminPhone = "";
  final SendSmsController sendSms = SendSmsController();
  bool isAboveFiveThousand = false;

  bool isPosting = false;
  void _startPosting()async{
    setState(() {
      isPosting = true;
    });
    await Future.delayed(const Duration(seconds: 4));
    setState(() {
      isPosting = false;
    });
  }


  fetchAdmin() async {
    const agentUrl = "https://fnetghana.xyz/admin_user";
    final agentLink = Uri.parse(agentUrl);
    http.Response res = await http.get(agentLink);
    if (res.statusCode == 200) {
      final codeUnits = res.body;
      var jsonData = jsonDecode(codeUnits);
      var myUser = jsonData[0];
      setState(() {
        adminPhone = myUser['phone'];
      });
    }
  }
  processDeposit() async {
    const registerUrl = "https://fnetghana.xyz/post_cash_deposit/";
    final myLink = Uri.parse(registerUrl);
    final res = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {

      "reason": _reasonController.text,
      "amount": _amount.text,
      "app_version" : "4"
    });
    if (res.statusCode == 201) {
      String telnum1 = adminPhone;
      telnum1 = telnum1.replaceFirst("0", '+233');
      sendSms.sendMySms(telnum1, "FNET",
          "Hello Admin,${username.capitalize} just made an expense request of GHC${_amount.text},kindly login into Fnet and approve.Thank you");
      Get.offAll(() => const MyBottomNavigationBar());
    } else {

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
    fetchAdmin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Make An Expense Request"),
        backgroundColor: primaryColor,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 40,),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: _reasonController,
                      cursorColor: primaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(
                          labelText: "Enter reason",
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
                          return "Please enter your reason";
                        }
                      },

                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: _amount,
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
                  const SizedBox(height: 30,),
                  isPosting ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 5,
                      color: primaryColor,
                    ),
                  ) : RawMaterialButton(
                    onPressed: () {
                      _startPosting();
                      if (!_formKey.currentState!.validate()) {
                        return;
                      } else {
                          processDeposit();
                      }
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
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
