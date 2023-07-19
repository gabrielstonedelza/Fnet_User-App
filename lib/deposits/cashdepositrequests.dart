import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../controllers/logincontroller.dart';
import '../controllers/usercontroller.dart';
import '../loadingui.dart';
import '../static/app_colors.dart';
import '../views/homepage.dart';

class CashDepositRequests extends StatefulWidget {
  const CashDepositRequests({Key? key}) : super(key: key);

  @override
  State<CashDepositRequests> createState() => _CashDepositRequestsState();
}

class _CashDepositRequestsState extends State<CashDepositRequests> {
  List allAgents = [];
  var items;
  bool isLoading = true;
  late String uToken = "";
  final storage = GetStorage();
  late String username = "";
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController = TextEditingController();
  var _currentSelectedAgent = "boss";
  List myAgents = [];
  int agentGivingMoney = 0;
  LoginController loginController = Get.find();
  UserController userController = Get.find();

  bool isPosting = false;

  void _startPosting() async {
    setState(() {
      isPosting = true;
    });
    await Future.delayed(const Duration(seconds: 4));
    setState(() {
      isPosting = false;
    });
  }


  fetchAgents() async {
    const url = "https://fnetghana.xyz/all_agents/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    },);

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      var agents = json.decode(jsonData);
      allAgents.assignAll(agents);
      for(var i in allAgents){
        if(!myAgents.contains(i['username'])){
          myAgents.add(i['username']);
        }
      }
    }
    setState(() {
      isLoading = false;
      allAgents = allAgents;
    });
  }
  processCashRequest() async {
    const depositUrl = "https://fnetghana.xyz/add_cash_request/";
    final myLink = Uri.parse(depositUrl);
    final res = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "agent1": userController.userProfileId,
      "agent2": agentGivingMoney.toString(),
      "amount": _amountController.text,
    });
    if (res.statusCode == 201) {
      Get.snackbar("Congratulations", "Request sent for approval",
          colorText: defaultTextColor,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackColor);

      setState(() {
        _currentSelectedAgent = "boss";
        _amountController.text = "";
      });
      // Get.offAll(()=> const MyBottomNavigationBar());
      Get.offAll(() => const HomePage(message: null,));
    } else {
      Get.snackbar("Request Error", res.body.toString(),
          colorText: defaultTextColor,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackColor);
    }
  }


  @override
  void initState(){
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
    fetchAgents();

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Request Cash"),
          backgroundColor: primaryColor,
        ),
      body:isLoading ? const LoadingUi() : ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text("Select Agent",style:TextStyle(fontWeight:FontWeight.bold,fontSize: 15)),
                      const SizedBox(height:10),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey, width: 1)),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0, right: 10),
                            child: DropdownButton(
                              isExpanded: true,
                              underline: const SizedBox(),
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 20),
                              items: myAgents.map((dropDownStringItem) {
                                return DropdownMenuItem(
                                  value: dropDownStringItem,
                                  child: Text(dropDownStringItem),
                                );
                              }).toList(),
                              onChanged: (newValueSelected) {
                                // print(newValueSelected);
                                for(var i in allAgents){
                                  if(i['username'] == newValueSelected){
                                    setState(() {
                                      agentGivingMoney = i['id'];
                                    });
                                  }
                                }
                                // print(agentGivingMoney.toString());
                                _onDropDownItemSelectedAgent(newValueSelected);
                              },
                              value: _currentSelectedAgent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height:20),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextFormField(
                          controller: _amountController,
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
                            if (value!.isEmpty) {
                              return "Please enter amount";
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 20,),
                      isPosting  ? const Center(
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
                            processCashRequest();
                          }
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        elevation: 8,
                        fillColor: primaryColor,
                        splashColor: defaultColor,
                        child: const Text(
                          "Save",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20,),
                  const Center(
                    child: Text("NB: Please click on dropdown and select boss again if you want to request from boss.",style:TextStyle(fontWeight: FontWeight.bold, fontSize: 20,)),
                  )
                ],
              ),
            ),
          )
        ],
      )
    );
  }
  void _onDropDownItemSelectedAgent(newValueSelected) {
    setState(() {
      _currentSelectedAgent = newValueSelected;
    });
  }
}
