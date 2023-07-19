
import 'dart:async';
import 'dart:convert';

import 'package:direct_dialer/direct_dialer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:fnet_new/views/bottomnavigation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ussd_advanced/ussd_advanced.dart';

import '../sendsms.dart';
import '../views/customerregistration.dart';

class MomoDeposit extends StatefulWidget {
  const MomoDeposit({Key? key}) : super(key: key);

  @override
  _MomoDepositState createState() => _MomoDepositState();
}

class _MomoDepositState extends State<MomoDeposit> {
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
  bool hasAmount = false;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController = TextEditingController();
  late final TextEditingController _agentPhoneController = TextEditingController();
  late final TextEditingController _depositorNameController = TextEditingController();
  late final TextEditingController _depositorPhoneController = TextEditingController();
  late final TextEditingController _referenceController = TextEditingController();

  final List mobileMoneyNetworks = [
    "Select Network",
    "Mtn",
  ];

  final List depositTypes = [
    "Select Deposit Type",
    "Merchant",
    "Agent",
  ];

  var _currentSelectedNetwork = "Select Network";
  var _currentSelectedType = "Select Deposit Type";
  late String uToken = "";
  final storage = GetStorage();
  late String username = "";
  late String mtnEcashNow = "";
  late String tigoAirtelEcashNow = "";
  late String vodafoneEcashNow = "";
  late String physicalNow = "";
  late String ecashNow = "";
  bool isRegular = false;
  final SendSmsController sendSms = SendSmsController();
  bool isDirect = false;
  bool isCustomer = false;
  late List customersPhone = [];
  bool fetchingCustomerAccounts = true;
  bool isLoading = true;
  late List customer = [];
  late List allCustomers = [];


  fetchCustomers() async {
    const url = "https://fnetghana.xyz/all_customers/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink);

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allCustomers = json.decode(jsonData);
      for (var i in allCustomers) {
        customersPhone.add(i['phone']);
      }
    }
    setState(() {
      isLoading = false;
    });
  }


  Future<void> dialCashInMtn(String customerNumber,String amount) async {
    UssdAdvanced.multisessionUssd(code: "*171*3*1*$customerNumber*$customerNumber*$amount#",subscriptionId: 1);
  }

  Future<void> dialPayToAgent(String customerNumber,String amount,String reference) async {
    UssdAdvanced.multisessionUssd(code: "*171*1*1*$customerNumber*$customerNumber*$amount*$reference#",subscriptionId: 1);
  }

  Future<void> dialPayToMerchant(String merchantId,String amount,String reference) async {
    UssdAdvanced.multisessionUssd(code: "*171*1*2*$merchantId*$amount*$reference#",subscriptionId: 1);
  }


  // Future<void> dialTigo() async {
  //   final dialer = await DirectDialer.instance;
  //   await dialer.dial('*110\%23#');
  // }
  // Future<void> dialVodafone() async {
  //   final dialer = await DirectDialer.instance;
  //   await dialer.dial('*110\%23#');
  // }


  processMomoDeposit() async {
    const registerUrl = "https://fnetghana.xyz/post_momo_deposit/";
    final myLink = Uri.parse(registerUrl);
    final res = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "customer_phone": _agentPhoneController.text.trim(),
      "reference": _referenceController.text.trim(),
      "depositor_name": _depositorNameController.text.trim(),
      "depositor_number": _depositorPhoneController.text.trim(),
      "network": _currentSelectedNetwork,
      "type": _currentSelectedType,
      "amount": _amountController.text.trim(),
    });

    if (res.statusCode == 201) {
      Get.snackbar("Congratulations", "Transaction was successful",
          colorText: defaultTextColor,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackColor);
      String telnum = _depositorPhoneController.text;
      telnum = telnum.replaceFirst("0", '+233');
      sendSms.sendMySms(telnum, "FNET",
          "Dear ${_depositorNameController.text}, your MTN deposit of ${_amountController.text}  ${_agentPhoneController.text} at F-NET is successful. For more information call 0244950505 Thanks");
      if(_currentSelectedNetwork == "Mtn"){
        var mtnenow = double.parse(mtnEcashNow) - double.parse(_amountController.text);
        // var enow = double.parse(ecashNow) - double.parse(_amountController.text);
        // var phynow = double.parse(physicalNow) + double.parse(_amountController.text);

        storage.write("mtnecashnow", mtnenow.round());
        // storage.write("physicalnow", phynow.round());
        // storage.write("ecashnow", enow.round());
      }

      // if(_currentSelectedNetwork == "AirtelTigo"){
      //   var tigoenow = double.parse(tigoAirtelEcashNow) - double.parse(_amountController.text);
      //   var enow = double.parse(ecashNow) - double.parse(_amountController.text);
      //   var phynow = double.parse(physicalNow) + double.parse(_amountController.text);
      //   storage.write("tigoairtelecashnow", tigoenow.round());
      //   storage.write("physicalnow", phynow.round());
      //   storage.write("ecashnow", enow.round());
      // }
      // if(_currentSelectedNetwork == "Vodafone"){
      //   var vodaenow = double.parse(vodafoneEcashNow) - double.parse(_amountController.text);
      //   var enow = double.parse(ecashNow) - double.parse(_amountController.text);
      //   var phynow = double.parse(physicalNow) + double.parse(_amountController.text);
      //   storage.write("vodafoneecashnow", vodaenow.round());
      //   storage.write("physicalnow", phynow.round());
      //   storage.write("ecashnow", enow.round());
      // }
      Get.offAll(() => const MyBottomNavigationBar());
      if(_currentSelectedNetwork == "Mtn"){
        // if(_currentSelectedType == "Customer" && _currentSelectedNetwork == "Mtn"){
        //   dialCashInMtn(_agentPhoneController.text.trim(),_amountController.text.trim());
        //   Get.back();
        // }
        if(_currentSelectedType == "Merchant" && _currentSelectedNetwork == "Mtn"){
          dialPayToMerchant(_agentPhoneController.text.trim(),_amountController.text.trim(),_referenceController.text.trim());
          Get.back();
        }
        if(_currentSelectedType == "Agent" && _currentSelectedNetwork == "Mtn"){
          dialPayToAgent(_agentPhoneController.text.trim(),_amountController.text.trim(),_referenceController.text.trim());
          Get.back();
        }
      }
      // if(_currentSelectedNetwork == "Vodafone"){
      //   dialVodafone();
      //   Get.back();
      // }
      // if(_currentSelectedNetwork == "AirtelTigo"){
      //   dialTigo();
      //   Get.back();
      // }

    } else {
      Get.snackbar("Request Error", res.body.toString(),
          colorText: defaultTextColor,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackColor);
    }
  }
  late List mySmss = [];

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
    if (storage.read("physicalnow") != null) {
      setState(() {
        physicalNow = storage.read("physicalnow").toString();
      });
    }
    if (storage.read("ecashnow") != null) {
      setState(() {
        ecashNow = storage.read("ecashnow").toString();
      });
    }

    if(storage.read("mtnecashnow") != null){
      setState(() {
        mtnEcashNow = storage.read("mtnecashnow").toString();
      });
    }
    // if(storage.read("tigoairtelecashnow") != null){
    //   setState(() {
    //     tigoAirtelEcashNow = storage.read("tigoairtelecashnow").toString();
    //   });
    // }
    //
    // if(storage.read("vodafoneecashnow") != null){
    //   setState(() {
    //     vodafoneEcashNow = storage.read("vodafoneecashnow").toString();
    //   });
    // }
    fetchCustomers();
  }

  @override
  void dispose(){
    super.dispose();
    _amountController.dispose();
    _agentPhoneController.dispose();
    _depositorNameController.dispose();
    _depositorPhoneController.dispose();
    _referenceController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mtn Pay To"),
        backgroundColor: primaryColor,
      ),
      body:  ListView(
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
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      // onChanged: (value) {
                      //   if (value.length == 10 &&
                      //       customersPhone.contains(value)) {
                      //     Get.snackbar("Success", "Customer is in system",
                      //         colorText: defaultTextColor,
                      //         snackPosition: SnackPosition.TOP,
                      //         backgroundColor: snackColor);
                      //
                      //     setState(() {
                      //       isCustomer = true;
                      //     });
                      //   } else if (value.length == 10 &&
                      //       !customersPhone.contains(value)) {
                      //     Get.snackbar(
                      //         "Customer Error", "Customer is not in system",
                      //         colorText: defaultTextColor,
                      //         snackPosition: SnackPosition.TOP,
                      //         backgroundColor: Colors.red);
                      //     setState(() {
                      //       isCustomer = false;
                      //     });
                      //     Timer(const Duration(seconds: 3),
                      //             () => Get.to(() => const CustomerRegistration()));
                      //   }
                      // },
                      controller: _agentPhoneController,
                      cursorColor: primaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(
                          prefixIcon:
                          const Icon(Icons.person, color: secondaryColor),
                          labelText: "Enter agent's number",
                          labelStyle: const TextStyle(color: secondaryColor),
                          focusColor: primaryColor,
                          fillColor: primaryColor,
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: primaryColor, width: 2),
                              borderRadius: BorderRadius.circular(12)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter customer number";
                        }
                      },
                    ),
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 10,),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey, width: 1)),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0, right: 10),
                            child: DropdownButton(
                              hint: const Text("Select Network"),
                              isExpanded: true,
                              underline: const SizedBox(),

                              items: mobileMoneyNetworks.map((dropDownStringItem) {
                                return DropdownMenuItem(
                                  value: dropDownStringItem,
                                  child: Text(dropDownStringItem),
                                );
                              }).toList(),
                              onChanged: (newValueSelected) {
                                _onDropDownItemSelectedNetwork(newValueSelected);
                              },
                              value: _currentSelectedNetwork,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey, width: 1)),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0, right: 10),
                            child: DropdownButton(
                              hint: const Text("Select Deposit Type"),
                              isExpanded: true,
                              underline: const SizedBox(),

                              items: depositTypes.map((dropDownStringItem) {
                                return DropdownMenuItem(
                                  value: dropDownStringItem,
                                  child: Text(dropDownStringItem),
                                );
                              }).toList(),
                              onChanged: (newValueSelected) {
                                _onDropDownItemSelectedDepositTypes(newValueSelected);
                                if(newValueSelected == "Customer") {
                                  setState(() {
                                    isDirect = true;
                                  });
                                }
                                else{
                                  setState(() {
                                    isDirect = false;
                                  });
                                }
                              },
                              value: _currentSelectedType,
                            ),
                          ),
                        ),
                      ),
               isDirect ?  Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextFormField(
                          controller: _depositorNameController,
                          cursorColor: primaryColor,
                          cursorRadius: const Radius.elliptical(10, 10),
                          cursorWidth: 10,
                          decoration: InputDecoration(
                              prefixIcon:
                              const Icon(Icons.person, color: secondaryColor),
                              labelText: "Enter depositors name",
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
                            if (value!.isEmpty) {
                              return "Please enter depositors name";
                            }
                          },
                        ),
                      ) : Container(),
                      isDirect ? Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextFormField(
                          controller: _depositorPhoneController,
                          cursorColor: primaryColor,
                          cursorRadius: const Radius.elliptical(10, 10),
                          cursorWidth: 10,
                          decoration: InputDecoration(
                              prefixIcon:
                              const Icon(Icons.person, color: secondaryColor),
                              labelText: "Enter depositors phone number",
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
                              return "Please enter depositors phone number";
                            }
                          },
                        ),
                      ) : Container(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextFormField(
                          onChanged: (value){
                            if(value.length > 1){
                              setState(() {
                                hasAmount = true;
                              });
                            }
                            if(value == ""){
                              setState(() {
                                hasAmount = false;
                              });
                            }
                          },
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
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextFormField(
                          controller: _referenceController,
                          cursorColor: primaryColor,
                          cursorRadius: const Radius.elliptical(10, 10),
                          cursorWidth: 10,
                          decoration: InputDecoration(

                              labelText: "Enter reference",
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
                            if (value!.isEmpty) {
                              return "Please enter reference";
                            }
                          },
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),
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

                            if(_currentSelectedType == "Select Deposit Type" || _currentSelectedNetwork == "Select Network"){
                              Get.snackbar("Bank Error", "Please select customers bank from the list",colorText: Colors.white,backgroundColor: Colors.red,snackPosition: SnackPosition.BOTTOM);

                              return;
                            }
                            else{
                              Get.snackbar("Please wait", "processing",
                                  colorText: defaultTextColor,
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: snackColor);
                              processMomoDeposit();
                            }
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
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _onDropDownItemSelectedNetwork(newValueSelected) {
    setState(() {
      _currentSelectedNetwork = newValueSelected;
    });
  }

  void _onDropDownItemSelectedDepositTypes(newValueSelected) {
    setState(() {
      _currentSelectedType = newValueSelected;
    });
  }
}
